Pebbl App from Thinkum.Space
============================

**Introducing Pebbl App**

## Developing with the Pebbl App Framework

### GTK Support in Pebbl App

In order to develop with the GTK and GNOME support in Pebbl App, the
[Ruby-GNOME][ruby-gnome] gems and other required software libraries must
be installed.


**SUSE, openSUSE***

GObject Introspection development files should be installed before
installing the [Ruby-GNOME][ruby-gnome] gems. This will provide
pkgconfig information and development headers for GObject Introspection
in [Ruby-GNOME][ruby-gnome].

Using the **zypper(8)** package management framework on openSUSE:

~~~~
$ zypper search --provides "pkgconfig(gobject-introspection-1.0)"
S  | Name                        | Summary                                 | Type
---+-----------------------------+-----------------------------------------+--------
   | gobject-introspection-devel | GObject Introspection Development Files | package
$ sudo zypper install gobject-introspection-devel
~~~~

GTK and other GNOME libraries may typically be installed as part of a
desktop environment on the host. These libraries should be installed
separately along with any corresponding typelib data, previous to
installing the [Ruby-GNOME][ruby-gnome] gems.

**Debian-Based Distributions**

On Debian hosts, the set of installation dependencies for
[Ruby-GNOME][ruby-gnome] can be resolved by installing the
`ruby-gnome` Debian package.

The corresponding '-dev' package should be installed, to ensure that
extensions can be built for the Ruby installation on the host.

~~~~
$ sudo bash -c 'apt-get update && apt-get install ruby-gnome ruby-gnome-dev'
~~~~

**FreeBSD**

On FreeBSD hosts, the set of installation dependencies for
[Ruby-GNOME][ruby-gnome] can be resolved by installing the
`rubygem-gnome` FreeBSD package.

Similar to the approach with Debian hosts, this will install the latest
[Ruby-GNOME][ruby-gnome] packages for the Ruby version used in building
the package repository configured on the host. This will ensure that the
gems are installed, along with depdendencies for each.

~~~~
$ sudo pkg install rubygem-gnome
~~~~

**All Platforms**

A **bundler(1)** _path_ can be configured for this project, such as in
order to install any required gems under the common `vendor/bundle` path
in the working tree.

~~~~
$ cd source_tree && bundle config set path vendor/bundle
~~~~

This will serve to ensure that the gems are configured and built
independent of any gems installed from the host package management
system or **gem(1)**.

When installing under a _bundle path_, bundler will use the latest
gem versions available from [Ruby Gems][rubygems] and within the set of
gem version requirements in this project.

**Compiler Toolchain**

For developing with [Ruby-GNOME][ruby-gnome] and other gems providing
gem extensions in C and C++ programming languages, a **C compiler toolkit**
and **GNU Make** should also be installed. These would be used for building
the gem extensions under the gem installation with **bundler(1)**.

Typically, the extensions will be built with the same compiler toolchain
that was used when building the Ruby implementation.

For example, with openSUSE Tumbleweed:

~~~
irb(main):001:0> RbConfig::CONFIG['CC']
=> "gcc"
irb(main):002:0> RbConfig::CONFIG['CC_VERSION_MESSAGE'].split("\n")[0]
=> "gcc (SUSE Linux) 12.1.0"
~~~

**Alternative: Using Locally Installed Gems for Dependencies**

If all of the dependencies for the Pebbl App project are available and
installed, such as installed from the host package management system and
`gem install`, then bundler can be configured for local installation
only.

For a clean installation using only the locally installed gems:

~~~
$ cd source_tree
$ for OBJ in Gemfile.lock .bundle/config vendor/bundle ; do
   if [ -e ${OBJ} ]; then mv ${OBJ} ${OBJ}.bak; fi; done
$ bundle install --local --with=development
~~~~

When all gem dependencies for the project can be met from gems that are
already installed, then this provides an alternative to fetching,
building, and installing the gems for this project only.

**Development Dependencies**

This project's development dependencies can be installed separately.

For example, selecting development dependencies during
**bundle-install(1)**:

~~~~
$ cd source_tree && bundle install --with=development
~~~~

## Running the Tests

Once all dependencies are installed, tests can be evaluated using **rspec**

~~~~
$ bundler exec rspec
~~~~

If **Xvfb** is installed, this virtual X server can be used to provide a
display environment for the tests.

~~~~
$ Xvfb :10 & env DISPLAY=:10 bundler exec rspec
~~~~

**Xvfb** may typically be available via the host package management system

* **openSUSE:** `xorg-x11-server-Xvfb`
* **Debian:** `xvfb`
* **FreeBSD:** `xorg-vfbserver` (`x11-servers/xorg-vfbserver`)


### Primary Work Areas

#### Project Tooling

The `pebbl_app-support` gem provides some generic support for projects.
This support code has been organized under the **PebblApp::Project**
module, available with the gem `pebbl_app-support`

- **PebblApp::Project::YSpec** providing support for a YAML-based
  gemspec configuration, for projects publishing any one or more
  gemspecs within a single source tree.

- **PebblApp::Project::ProjectModule** providing a Ruby module
  definition for _extension by include_ in other Ruby source
  modules. This module provides methods for defining autoloads within
  the immediate namespace of an including module, with filenames
  resolved relative to a source pathname interpolated or configured
  for the including module. Using autoloads as resolved relative to
  some configured source path, this may serve to minimize the number of
  `require` calls needed for resolving all Ruby constant references
  within any single Ruby source file.

#### Application Support

The `pebbl_app-support` gem  provides reusable code for Pebbl App
applications, within the **PebblApp::Support** module. This includes the
generic **PebblApp::Support::App** class, which can be extended
individually. This class is used in **PebblApp::GtkSupport::GtkApp**.

#### GTK Applications (Prototyping)

The `pebbl_app-gtk_support` and `riview` gems serve as a combined work
area for GNOME application support in Ruby.

The `riview` gem may serve as a proof of concept for Glade/UI builder
support with GTK and [Ruby-GNOME][ruby-gnome]. This gem uses `rikit` in
a prototype for a documentation browser in Ruby.

The `pebbl_app-gtk_support` gem provides an application class for GTK
applications in Ruby, **PebblApp::GtkSupport::GtkApp**

## History

The [PebblApp project][pebblapp] project was created originally to serve
as a central development project for a small number of Ruby projects
developed at Thinkum.Space.

#### Sandbox

The sandbox sections of the project's source tree retain some earlier
Ruby gem prototypes, from previous to the development of this
centralized project at Thinkum.Space.

[pebblapp]: https://github.com/rubyblox/pebbl_app
[rubygems]: https://www.rubygems.org/
[ruby-gnome]: https://github.com/ruby-gnome/ruby-gnome


<!--  LocalWords:  Pebbl Thinkum GTK openSUSE GObject pkgconfig zypper -->
<!--  LocalWords:  gobject devel sudo typelib dev FreeBSD rubygem cd mv -->
<!--  LocalWords:  depdendencies bundler config rubygems Toolchain irb -->
<!--  LocalWords:  toolchain gcc Gemfile bak fi rspec Xvfb env xorg gtk -->
<!--  LocalWords:  xvfb vfbserver pebbl YAML gemspec gemspecs autoloads -->
<!--  LocalWords:  namespace pathname riview UI rikit PebblApp pebblapp -->
