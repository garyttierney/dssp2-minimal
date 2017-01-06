# Minimal Defensec SELinux Security Policy Version 2

## Introduction

Minimal DSSP (Version2) was designed to provide a template to build the widest array of configurations on top of that address custom access control challenges. A delicate balance was struck to provide just enough tooling to allow one to focus on productivity by making as little assumptions as possible about specific use cases.

A comprehensive set of optional templates, class mappings, class permissions and macros are provided by default to encourage efficient, consistent, and self documenting policy configuration.

## Leverages Common Intermediate Language

Common Intermediate Language is a language that is native to SELinux and that implements functionality inspired by popular features of Tresys Reference policy without the need for a pre-processor.

The source policy oriented nature of CIL provides enhanced accessibility and modularity. Text-based configuration makes it easier to resolve dependencies and to profile.

New language features allows authors to focus on creativity and productivity. Clear and simple syntax makes it easy to parse and generate security policy.

## Requirements

DSSP requires `semodule` or `secilc` version 2.4 or higher.

SELinux should be enabled in the Linux kernel, your file systems should support `security extended attributes` and this support should be enabled in the Linux kernel.

## Installation

    git clone --recurse https://github.com/defensec/dssp2-minimal
    cd dssp2-minimal
    make install-semodule
	cat > /etc/selinux/config <<EOF
    SELINUX=enforcing
    SELINUXTYPE=dssp2-minimal
    EOF
    echo "-F" > /.autorelabel
    reboot

## Known issues

Various `systemd` socket units and `systemd-tmpfiles` configuration snippets may refer to `/var/run` instead of `/run` and this causes them to create content with the wrong security context.

Fedora:

	cp /usr/lib/tmpfiles.d/pam.conf /etc/tmpfiles.d/ && \
		sed -i 's/\/var\/run/\/run/' /etc/tmpfiles.d/pam.conf
	cp /usr/lib/tmpfiles.d/libselinux.conf /etc/tmpfiles.d/ && \
		sed -i 's/\/var\/run/\/run/' /etc/tmpfiles.d/libselinux.conf

Debian:

	cp /usr/lib/tmpfiles.d/sshd.conf /etc/tmpfiles.d/
		sed -i 's/\/var\/run/\/run/' /etc/tmpfiles.d/sshd.conf

	cp /lib/systemd/system/dbus.socket /etc/systemd/system/
		sed -i 's/\/var\/run/\/run/' /etc/systemd/system/dbus.socket

	cp /lib/systemd/system/avahi-daemon.socket /etc/systemd/system/
		sed -i 's/\/var\/run/\/run/' /etc/systemd/system/avahi-daemon.socket


## Getting started with Hello World!

    echo "Hello World! from: `id -Z`" > /usr/local/bin/helloworld.sh
    chmod +x /usr/local/bin/helloworld.sh
    cat > helloworld.cil <<EOF
    (block helloworld
        (blockinherit system_agent_template)

        (typepermissive subj)

        (filecon "/usr/bin/helloworld\.sh" file cmd_file_context)
    )
    (in sys
        (call helloworld.auto_subj_type_transition
            (
                isid
            )
        )
    )
    EOF
    semodule -i helloworld.cil.sh
    restorecon /usr/local/bin/helloworld.sh
    helloworld.sh


## Resources

* [Common Intermediate Language](https://github.com/SELinuxProject/selinux/blob/master/secilc/docs/README.md) Learn to speak CIL
