# -*- Mode: makefile; indent-tabs-mode: t -*-

.PHONY: all check clean policy install-config install-semodule

include build.conf

BINDIR ?= /bin
DESTDIR ?= /
INSTALL = $(USRBINDIR)/install
MKDIR = $(BINDIR)/mkdir
RM = $(BINDIR)/rm
SBINDIR ?= /sbin
SECILC = $(USRBINDIR)/secilc
SEMODULE = $(USRSBINDIR)/semodule
SHAREDSTATEDIR ?= /var/lib
SYSCONFDIR ?= /etc
USRBINDIR ?= /usr/bin
USRSBINDIR ?= /usr/sbin

POLICY_CONFIG_SOURCES = config/customizable_types \
	config/dbus_contexts \
	config/default_contexts \
	config/default_type \
	config/failsafe_context \
	config/file_contexts.subs_dist \
	config/media \
	config/openssh_contexts \
	config/removable_context \
	config/securetty_types \
	config/x_contexts

BASE_POLICY_SOURCES = policy/base/access_vectors.cil \
	policy/base/class_maps.cil \
	policy/base/class_permissions.cil \
	policy/base/commands.cil \
	policy/base/devices.cil \
	policy/base/files.cil \
	policy/base/file_systems.cil \
	policy/base/ibac.cil \
	policy/base/initial_sids.cil \
	policy/base/libraries.cil \
	policy/base/mcs.cil \
	policy/base/misc_templates.cil \
	policy/base/network.cil \
	policy/base/policy_config.cil \
	policy/base/rbac.cil \
	policy/base/rbacsep.cil \
	policy/base/security.cil \
	policy/base/storage.cil \
	policy/base/subjects.cil \
	policy/base/system.cil \
	policy/base/terminals.cil

MINIMAL_POLICY_SOURCES = policy/minimal.cil

all: clean policy.$(POLICY_VERSION)

clean:
	$(RM) -f policy.$(POLICY_VERSION) file_contexts

$(POLICY_VERSION): $(BASE_POLICY_SOURCES) $(MINIMAL_POLICY_SOURCES)
	$(SECILC) --policyvers=$(POLICY_VERSION) --o="$@" $^

policy.%: $(BASE_POLICY_SOURCES) $(MINIMAL_POLICY_SOURCES)
	$(SECILC) --policyvers=$* --o="$@" $^

install-config: $(POLICY_CONFIG_SOURCES)
	$(MKDIR) -p $(DESTDIR)/$(SYSCONFDIR)/selinux/$(POLICY_NAME)/contexts/files
	$(MKDIR) -p $(DESTDIR)/$(SYSCONFDIR)/selinux/$(POLICY_NAME)/contexts/users
	$(MKDIR) -p $(DESTDIR)/$(SYSCONFDIR)/selinux/$(POLICY_NAME)/logins
	$(INSTALL) -m0644 config/customizable_types $(DESTDIR)/$(SYSCONFDIR)/selinux/$(POLICY_NAME)/contexts/customizable_types
	$(INSTALL) -m0644 config/dbus_contexts $(DESTDIR)/$(SYSCONFDIR)/selinux/$(POLICY_NAME)/contexts/dbus_contexts
	$(INSTALL) -m0644 config/default_contexts $(DESTDIR)/$(SYSCONFDIR)/selinux/$(POLICY_NAME)/contexts/default_contexts
	$(INSTALL) -m0644 config/default_type $(DESTDIR)/$(SYSCONFDIR)/selinux/$(POLICY_NAME)/contexts/default_type
	$(INSTALL) -m0644 config/failsafe_context $(DESTDIR)/$(SYSCONFDIR)/selinux/$(POLICY_NAME)/contexts/failsafe_context
	$(INSTALL) -m0644 config/file_contexts.subs_dist $(DESTDIR)/$(SYSCONFDIR)/selinux/$(POLICY_NAME)/contexts/files/file_contexts.subs_dist
	$(INSTALL) -m0644 config/media $(DESTDIR)/$(SYSCONFDIR)/selinux/$(POLICY_NAME)/contexts/files/media
	$(INSTALL) -m0644 config/openssh_contexts $(DESTDIR)/$(SYSCONFDIR)/selinux/$(POLICY_NAME)/contexts/openssh_contexts
	$(INSTALL) -m0644 config/removable_context $(DESTDIR)/$(SYSCONFDIR)/selinux/$(POLICY_NAME)/contexts/removable_context
	$(INSTALL) -m0644 config/securetty_types $(DESTDIR)/$(SYSCONFDIR)/selinux/$(POLICY_NAME)/contexts/securetty_types

install-semodule: install-config $(BASE_POLICY_SOURCES) $(MINIMAL_POLICY_SOURCES)
	$(MKDIR) -p $(DESTDIR)/$(SHAREDSTATEDIR)/selinux/$(POLICY_NAME)
	$(SEMODULE) --priority=100 -i $(BASE_POLICY_SOURCES) $(MINIMAL_POLICY_SOURCES) -N -s $(POLICY_NAME) -p $(DESTDIR)
