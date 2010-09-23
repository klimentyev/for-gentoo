# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-kernel/openvz-sources/openvz-sources-2.6.32.8.1.ebuild,v 1.1 2010/09/10 07:23:55 pva Exp $

inherit versionator

# Upstream uses string to version their releases. To make portage version
# comparisment working we have to use numbers instead of strings, that is 4th
# component of our version. So we have aivazovsky - 1, briullov - 2 and so on.
# Keep this string on top since we have to modify it each new release.
OVZ_CODENAME="dobrovolskiy"
OVZ_CODENAME_SUBRELEASE=$(get_version_component_range 5)

OVZ_KV="${OVZ_CODENAME}.${OVZ_CODENAME_SUBRELEASE}"

ETYPE="sources"

CKV=$(get_version_component_range 1-3)
OKV=${OKV:-${CKV}}
EXTRAVERSION=-${PN/-*}-${OVZ_KV}
KV_FULL=${CKV}${EXTRAVERSION}
if [[ ${PR} != r0 ]]; then
	KV_FULL+=-${PR}
	EXTRAVERSION+=-${PR}
fi

# ${KV_MAJOR}.${KV_MINOR}.${KV_PATCH} should succeed.
KV_MAJOR=$(get_version_component_range 1 ${OKV})
KV_MINOR=$(get_version_component_range 2 ${OKV})
KV_PATCH=$(get_version_component_range 3 ${OKV})

KERNEL_URI="mirror://kernel/linux/kernel/v${KV_MAJOR}.${KV_MINOR}/linux-${OKV}.tar.bz2"

K_KERNEL_SOURCES_PKG="sys-kernel/openvz-sources-${PVR}"
# Security patches for CVE-2010-3081, will be merged in next stable kernel release
K_KERNEL_PATCH_HOTFIXES="${FILESDIR}/hotfixes/2.6.32/x86-64-compat-test-rax-for-the-syscall-number-not-eax.patch
        ${FILESDIR}/hotfixes/2.6.32/x86-64-compat-retruncate-rax-after-ia32-syscall-entry-tracing.patch
        ${FILESDIR}/hotfixes/2.6.32/compat-make-compat_alloc_user_space-incorporate-the-access_ok.patch"
K_KERNEL_DISABLE_PR_EXTRAVERSION="0"
inherit sabayon-kernel

SLOT=${CKV}-${OVZ_KV}
if [[ ${PR} != r0 ]]; then
	SLOT+=-${PR}
fi

KEYWORDS="~amd64 ~x86"
IUSE=""

DESCRIPTION="Kernel binaries with OpenVZ patchset"
HOMEPAGE="http://www.openvz.org"
SRC_URI="${KERNEL_URI} ${ARCH_URI}
	http://download.openvz.org/kernel/branches/${CKV}/${CKV}-${OVZ_KV}/patches/patch-${OVZ_KV}-combined.gz"

UNIPATCH_STRICTORDER=1
UNIPATCH_LIST="${DISTDIR}/patch-${OVZ_KV}-combined.gz"

K_EXTRAEINFO="For more information about this kernel take a look at:
http://wiki.openvz.org/Download/kernel/${CKV}/${CKV}-${OVZ_KV}"

############################################
# binary part

# Sabayon patches
UNIPATCH_LIST="${UNIPATCH_LIST}
${FILESDIR}/sabayon-2.6.32/4200_fbcondecor-0.9.6.patch
"

pkg_preinst() {
	sabayon-kernel_pkg_preinst
	# Fixing up Makefile collision if already installed by
	# openvz-sources
	make_file="${ROOT}/usr/src/linux-${KV_FULL}/Makefile"
	[[ -f "${make_file}" ]] && rm "${make_file}"
}

pkg_postinst() {
	sabayon-kernel_pkg_postinst

	elog "You can find OpenVZ templates at:"
	elog "http://wiki.openvz.org/Download/template/precreated"

}
