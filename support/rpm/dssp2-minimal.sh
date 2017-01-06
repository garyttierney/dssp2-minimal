#!/bin/bash
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-

set -e
set -o pipefail

test -e /bin/dnf || retval=192

if [[ $retval = 192 ]]
then
    echo "/bin/dnf is required but not installed"
    exit
fi

__buildit ()
{
    MINHEAD=`/bin/curl -s \
        https://api.github.com/repos/defensec/dssp2-minimal/git/refs/heads/master \
            | /bin/grep "sha" | /bin/awk -F "\"" '{ print $4 }'`

    BASEHEAD=`/bin/curl -s \
        https://api.github.com/repos/defensec/dssp2-base/git/refs/heads/master \
            | /bin/grep "sha" | /bin/awk -F "\"" '{ print $4 }'`

    /bin/test -e ${HOME}/rpmbuild/SOURCES/dssp2-minimal-${MINHEAD}.tar.gz \
        || /bin/wget -q \
            https://github.com/defensec/dssp2-minimal/archive/${MINHEAD}/dssp2-minimal-${MINHEAD}.tar.gz \
                -O ${HOME}/rpmbuild/SOURCES/dssp2-minimal-${MINHEAD}.tar.gz

    /bin/test -e ${HOME}/rpmbuild/SOURCES/dssp2-base-${BASEHEAD}.tar.gz \
        || /bin/wget -q \
            https://github.com/defensec/dssp2-base/archive/${BASEHEAD}/dssp2-base-${BASEHEAD}.tar.gz \
                -O ${HOME}/rpmbuild/SOURCES/dssp2-base-${BASEHEAD}.tar.gz

    /bin/test -e ${HOME}/rpmbuild/SPECS/dssp2-minimal.spec \
        || /bin/wget -q \
            https://raw.githubusercontent.com/defensec/dssp2-minimal/master/support/rpm/dssp2-minimal.spec \
                -O ${HOME}/rpmbuild/SPECS/dssp2-minimal.spec

    /bin/sed -i \
        "s/%global commit0.*/%global commit0 $MINHEAD/" \
            ${HOME}/rpmbuild/SPECS/dssp2-minimal.spec

    /bin/sed -i \
        "s/%global commit1.*/%global commit1 $BASEHEAD/" \
            ${HOME}/rpmbuild/SPECS/dssp2-minimal.spec

    /bin/rpmbuild -ba ${HOME}/rpmbuild/SPECS/dssp2-minimal.spec
}

__devtree ()
{
    if ! /bin/test -d ${HOME}/rpmbuild
    then

        /bin/rpmdev-setuptree

        __buildit

        /bin/mv ${HOME}/rpmbuild/{RPMS/noarch/,SRPMS}/dssp2-*.rpm \
            ${HOME}/

        /bin/rm -rf ${HOME}/rpmbuild
    else

        __buildit
    fi
}

if [[ $UID = 0 ]]
then
    if ! /bin/rpm -q rpmdevtools rpm-build policycoreutils wget sed curl
    then

        /bin/dnf -y --setopt=install_weak_deps=false install \
            rpmdevtools policycoreutils wget sed curl

        __devtree

        /bin/dnf -y history undo last
    else

        __devtree
    fi

elif ! [[ $UID = 0 ]]
then
    test -e /bin/sudo || retval=192

    if [[ $retval = 192 ]]
    then
        echo "/bin/sudo is required but not installed"
        exit
    fi

    if ! /bin/sudo /bin/rpm -q rpmdevtools rpm-build policycoreutils wget sed curl
    then
        /bin/sudo /bin/dnf -y --setopt=install_weak_deps=false install \
            rpmdevtools policycoreutils wget sed curl

        __devtree

        /bin/sudo /bin/dnf -y history undo last
    else

        __devtree
    fi
fi

exit
#EOF
