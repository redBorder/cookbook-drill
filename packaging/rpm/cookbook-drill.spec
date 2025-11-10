Name: cookbook-drill
Version: %{__version}
Release: %{__release}
BuildArch: noarch
Summary: cookbook to install and configure drill in the redborder platform

License: AGPL 3.0
URL: https://github.com/redborder/cookbook-drill
Source0: %{name}-%{version}.tar.gz

%define debug_package %{nil}

%description
%{summary}

%prep
%setup -qn %{name}-%{version}

%build
true

%install
mkdir -p %{buildroot}/var/chef/cookbooks/drill
cp -a resources/* %{buildroot}/var/chef/cookbooks/drill
chmod -R 0755 %{buildroot}/var/chef/cookbooks/drill

%pre
if [ -d /var/chef/cookbooks/drill ]; then
  rm -rf /var/chef/cookbooks/drill
fi

%post
case "$1" in
  1) : ;;  # install
  2) su - -s /bin/bash -c 'source /etc/profile && rvm gemset use default && env knife cookbook upload drill' ;;
esac

%postun
if [ "$1" = 0 ] && [ -d /var/chef/cookbooks/drill ]; then
  rm -rf /var/chef/cookbooks/drill
fi

%files
%defattr(0755,root,root)
/var/chef/cookbooks/drill


%changelog
* Mon Nov 10 2025 Juan Soto <jsoto@redborder.com>
- Create Drill cookbook