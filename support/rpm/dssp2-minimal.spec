%global commit0 ...
%global shortcommit0 %(c=%{commit0}; echo ${c:0:7})
%global commit1 ...
%global shortcommit1 %(c=%{commit1}; echo ${c:0:7})

%define POLICYVER 30
%define POLICYCOREUTILSVER 2.5

Summary: Defensec SELinux Security Policy Version 2
Name: dssp2
Version: 0.1
Release: %(date +%Y%%m%%d)git%{shortcommit0}%{?dist}
License: Public Domain
Group: System Environment/Base
Source0: https://github.com/Defensec/dssp2-minimal/archive/%{commit0}/dssp2-minimal-%{commit0}.tar.gz
Source1: https://github.com/Defensec/dssp2-base/archive/%{commit1}/dssp2-base-%{commit1}.tar.gz
URL: https://github.com/Defensec/dssp2-minimal/wiki
Requires: policycoreutils >= %{POLICYCOREUTILSVER}
Conflicts: selinux-policy
BuildRequires: policycoreutils >= %{POLICYCOREUTILSVER}
BuildArch: noarch

%description
SELinux security policy written in native Common Intermediate Language
Provides the base Defensec SELinux Security Policy package.

%files
%defattr(-,root,root,-)
%{!?_licensedir:%global license %%doc}
%license LICENSE
%dir %{_sysconfdir}/selinux
%ghost %config(noreplace) %{_sysconfdir}/selinux/config
%ghost %{_sysconfdir}/sysconfig/selinux

%define fileList() \
%defattr(-,root,root,-) \
%dir %{_sysconfdir}/selinux/%1 \
%config(noreplace) %verify(not md5 size mtime) %{_sysconfdir}/selinux/%1/seusers \
%dir %{_sysconfdir}/selinux/%1/logins \
%dir %{_sharedstatedir}/selinux/%1/active \
%verify(not md5 size mtime) %{_sharedstatedir}/selinux/%1/semanage.read.LOCK \
%verify(not md5 size mtime) %{_sharedstatedir}/selinux/%1/semanage.trans.LOCK \
%dir %attr(700,root,root) %dir %{_sharedstatedir}/selinux/%1/active/modules \
%verify(not md5 size mtime) %{_sharedstatedir}/selinux/%1/active/modules/100 \
%dir %{_sysconfdir}/selinux/%1/policy/ \
%verify(not md5 size mtime) %{_sysconfdir}/selinux/%1/policy/policy.%{POLICYVER} \
%dir %{_sysconfdir}/selinux/%1/contexts \
%config(noreplace) %{_sysconfdir}/selinux/%1/contexts/customizable_types \
%config(noreplace) %{_sysconfdir}/selinux/%1/contexts/securetty_types \
%config(noreplace) %{_sysconfdir}/selinux/%1/contexts/dbus_contexts \
%config(noreplace) %{_sysconfdir}/selinux/%1/contexts/default_contexts \
%config(noreplace) %{_sysconfdir}/selinux/%1/contexts/openssh_contexts \
%config(noreplace) %{_sysconfdir}/selinux/%1/contexts/default_type \
%config(noreplace) %{_sysconfdir}/selinux/%1/contexts/failsafe_context \
%config(noreplace) %{_sysconfdir}/selinux/%1/contexts/removable_context \
%dir %{_sysconfdir}/selinux/%1/contexts/files \
%config(noreplace) %{_sysconfdir}/selinux/%1/contexts/files/media \
%config(noreplace) %{_sysconfdir}/selinux/%1/contexts/files/file_contexts.subs_dist \
%verify(not md5 size mtime) %{_sysconfdir}/selinux/%1/contexts/files/file_contexts \
%verify(not md5 size mtime) %{_sysconfdir}/selinux/%1/contexts/files/file_contexts.bin \
%verify(not md5 size mtime) %{_sysconfdir}/selinux/%1/contexts/files/file_contexts.homedirs \
%verify(not md5 size mtime) %{_sysconfdir}/selinux/%1/contexts/files/file_contexts.homedirs.bin \
%{_sharedstatedir}/selinux/%1/active/commit_num \
%{_sharedstatedir}/selinux/%1/active/users_extra \
%{_sharedstatedir}/selinux/%1/active/homedir_template \
%{_sharedstatedir}/selinux/%1/active/seusers \
%{_sharedstatedir}/selinux/%1/active/file_contexts \
%{_sharedstatedir}/selinux/%1/active/policy.kern \
%dir %{_sysconfdir}/selinux/%1/contexts/users \
%nil

%package minimal
Summary: Minimal Defensec SELinux Security Policy Version 2
Group: System Environment/Base
Requires(pre): policycoreutils >= %{POLICYCOREUTILSVER}
Requires(pre): dssp2 = %{version}-%{release}
Requires: dssp2 = %{version}-%{release}

%description minimal
SELinux security policy written in native Common Intermediate Language
Provides the minimal Defensec SELinux Security Policy package.

%files minimal
%fileList dssp2-minimal

%prep
%autosetup -n dssp2-minimal-%{commit0}
%autosetup -n dssp2-minimal-%{commit0} -a 1
rmdir policy/base
mv -f dssp2-base-%{commit1} policy/base

%build

%install
make DESTDIR=%{buildroot} install-semodule

%clean
rm -rf %{buildroot}

%post minimal
if [ ! -s /etc/selinux/config ]; then
echo
"
SELINUX=enforcing
SELINUXTYPE=dssp2-minimal
" > /etc/selinux/config

    ln -sf /etc/selinux/config /etc/sysconfig/selinux
    restorecon /etc/selinux/config 2> /dev/null || :
else
    . /etc/selinux/config
    [ "${SELINUXTYPE}" == "dssp2-minimal" ] && selinuxenabled && load_policy
fi
exit 0

%postun
if [ $1 = 0 ]; then
    setenforce 0 2> /dev/null
    if [ ! -s /etc/selinux/config ]; then
        echo "SELINUX=disabled" > /etc/selinux/config
    else
        sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
    fi
fi
exit 0

%triggerin -- pcre
selinuxenabled && semodule -nB

%changelog
* Fri Jan 6 2017 Dominick Grift <dac.override@gmail.com> - 0.1-%(date +%Y%%m%%d)git%{shortcommit0}
- Git snapshot
