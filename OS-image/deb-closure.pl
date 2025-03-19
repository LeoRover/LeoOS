use strict;
use Dpkg::Control;
use Dpkg::Deps;
use File::Basename;
use Getopt::Long;

my %args = ();
GetOptions(\%args, "package-list=s@");

my @toplevelPkgs = @ARGV;

my %packages;

foreach my $list (@{$args{"package-list"}}) {
    my ($packagesFile, $urlPrefix) = split(",", $list);

    print STDERR "parsing $packagesFile\n";

    # Parse the Packages file.
    open(my $packagesFh, '<', $packagesFile) or die;

    while (1) {
        my $cdata = Dpkg::Control->new(type => CTRL_TMPL_PKG);
        last if not $cdata->parse($packagesFh, $packagesFile);
        die unless defined $cdata->{Package};
        # print STDERR $cdata->{Package}, "\n";
        $packages{$cdata->{Package}} = { cdata => $cdata, urlPrefix => $urlPrefix };
    }

    close $packagesFh;
}

# Flatten a Dpkg::Deps dependency value into a list of package names.
sub getDeps {
    my $deps = shift;
    #print "$deps\n";
    if ($deps->isa('Dpkg::Deps::AND')) {
        my @res = ();
        foreach my $dep ($deps->get_deps()) {
            push @res, getDeps($dep);
        }
        return @res;
    } elsif ($deps->isa('Dpkg::Deps::OR')) {
        # Arbitrarily pick the first alternative.
        return getDeps(($deps->get_deps())[0]);
    } elsif ($deps->isa('Dpkg::Deps::Simple')) {
        return ($deps->{package});
    } else {
        die "unknown dep type";
    }
}

# Process the "Provides" and "Replaces" fields to be able to resolve
# virtual dependencies.
my %provides;

foreach my $package (sort {$a->{cdata}->{Package} cmp $b->{cdata}->{Package}} (values %packages)) {
    my $cdata = $package->{cdata};
    if (defined $cdata->{Provides}) {
        my @provides = getDeps(Dpkg::Deps::deps_parse($cdata->{Provides}));
        foreach my $name (@provides) {
            #die "conflicting provide: $name\n" if defined $provides{$name};
            #warn "provide by $cdata->{Package} conflicts with package with the same name: $name\n";
            next if defined $packages{$name};
            $provides{$name} = $cdata->{Package};
        }
    }
    # Treat "Replaces" like "Provides".
    if (defined $cdata->{Replaces}) {
        my @replaces = getDeps(Dpkg::Deps::deps_parse($cdata->{Replaces}));
        foreach my $name (@replaces) {
            next if defined $packages{$name};
            $provides{$name} = $cdata->{Package};
        }
    }
}

# Determine the closure of a package.
my %donePkgs;
my %depsUsed;
my %preDepsUsed;
my @order = ();

sub closePackage {
    my $pkgName = shift;
    print STDERR ">>> $pkgName\n";
    my $cdata = $packages{$pkgName}->{cdata};

    if (!defined $cdata) {
        die "unknown (virtual) package $pkgName"
            unless defined $provides{$pkgName};
        print STDERR "virtual $pkgName: using $provides{$pkgName}\n";
        $pkgName = $provides{$pkgName};
        $cdata = $packages{$pkgName}->{cdata};
    }

    die "unknown package $pkgName" unless defined $cdata;
    return if defined $donePkgs{$pkgName};
    $donePkgs{$pkgName} = 1;

    if (defined $cdata->{Provides}) {
        foreach my $name (getDeps(Dpkg::Deps::deps_parse($cdata->{Provides}))) {
            $provides{$name} = $cdata->{Package};
        }
    }

    my @preDepNames = ();

    if (defined $cdata->{'Pre-Depends'}) {
        print STDERR "    $pkgName: $cdata->{'Pre-Depends'}\n";
        my $deps = Dpkg::Deps::deps_parse($cdata->{'Pre-Depends'});
        die unless defined $deps;
        push @preDepNames, getDeps($deps);
    }

    foreach my $preDepName (@preDepNames) {
        closePackage($preDepName);
    }

    my @depNames = ();

    if (defined $cdata->{Depends}) {
        print STDERR "    $pkgName: $cdata->{Depends}\n";
        my $deps = Dpkg::Deps::deps_parse($cdata->{Depends});
        die unless defined $deps;
        push @depNames, getDeps($deps);
    }

    foreach my $depName (@depNames) {
        closePackage($depName);
    }

    push @order, $pkgName;
    $preDepsUsed{$pkgName} = \@preDepNames;
    $depsUsed{$pkgName} = \@depNames;
}

foreach my $pkgName (@toplevelPkgs) {
    closePackage $pkgName;
}

# Generate the output Nix expression.
print "# This is a generated file.  Do not modify!\n";
print "# Following are the Debian packages constituting the closure of: @toplevelPkgs\n\n";
print "{fetchurl}:\n\n";
print "[\n\n";
print "  [\n\n";

# Output the packages in strongly connected components.
my %done;
my %currentComponent;
my $newComponent = 0;
foreach my $pkgName (@order) {
    my $package = $packages{$pkgName};
    my $cdata = $package->{cdata};
    my $urlPrefix = $package->{urlPrefix};
    my @preDeps = @{$preDepsUsed{$pkgName}};

    foreach my $preDep (@preDeps) {
        $preDep = $provides{$preDep} if defined $provides{$preDep};
        next if defined $done{$preDep};
        $newComponent = 1;
        last;
    }

    if ($newComponent) {
        print "  ]\n\n";
        print "  [\n\n";
        $newComponent = 0;
        @done{keys %currentComponent} = values %currentComponent;
        %currentComponent = ();
    }

    $currentComponent{$pkgName} = 1;

    my $origName = basename $cdata->{Filename};
    my $cleanedName = $origName;
    $cleanedName =~ s/~//g;

    print "    (fetchurl {\n";
    print "      url = \"$urlPrefix/$cdata->{Filename}\";\n";
    print "      sha256 = \"$cdata->{SHA256}\";\n";
    print "      name = \"$cleanedName\";\n" if $cleanedName ne $origName;
    print "    })\n";
    print "\n";
}

print "  ]\n\n";
print "]\n";
