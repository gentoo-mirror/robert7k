# Copyright 2024 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit desktop java-pkg-2

DESCRIPTION="Free, DBMS-independent, cross-platform SQL query tool."
HOMEPAGE="http://www.sql-workbench.net/"
KEYWORDS="~amd64"
SRC_URI="http://www.sql-workbench.net/Workbench-Build${PV}.zip -> ${P}.zip"
SLOT="0"
# Actually, modified
LICENSE="Apache-2.0"

IUSE="firebird informix mssql mysql oracle postgres sybase"

DEPEND=">=virtual/jdk-11:*"
RDEPEND="
	${DEPEND}
	dev-java/log4j-api
	postgres? ( dev-java/jdbc-postgresql )
	mysql? ( dev-java/jdbc-mysql )
	mssql? ( dev-java/jdbc-mssqlserver )
	sybase? ( dev-java/jtds )
	informix? ( dev-java/jdbc-informix )
	firebird? ( dev-java/jdbc-jaybird )
	oracle? ( dev-java/jdbc-oracle-bin )
"

EANT_BUILD_XML="./scripts/build.xml"

EANT_BUILD_TARGET="init prepare compile make-jar"

S="${WORKDIR}"

src_install() {
	local install_dir="${EROOT}usr/share/${PN}";
	insinto "${install_dir}";

	java-pkg_dojar ${PN}.jar;

	for backend in ${IUSE}; do
		use "${backend}" && {
			local jb;
			if [ "${backend}" == "postgres" ]; then
				jb="postgresql";
			elif [ "${backend}" == "mssql" ]; then
				jb="mssqlserver";
			elif [ "${backend}" == "sybase" ]; then
				jb="jtds";
			elif [ "${backend}" == "firebird" ]; then
				jb="jaybird";
			elif [ "${backend}" == "oracle" ]; then
				jb="oracle-bin";
			else
				jb="${backend}";
			fi
			for jar in /usr/share/jdbc-${jb}/lib/*.jar; do
				java-pkg_regjar "${jar}"
			done;
		}
	done

	java-pkg_dolauncher "${PN}-console" --main workbench.console.SQLConsole --java_args "-Djava.awt.headless=true -Dvisualvm.display.name=SQLWorkbench -Xmx512m" --pkg_args "\${@}" --pwd "${install_dir}"
	java-pkg_dolauncher "${PN}" --main workbench.WbStarter --java_args "-Dvisualvm.display.name=SQLWorkbench -Xmx512m" --pkg_args "\${@}" --pwd "${install_dir}"

	make_desktop_entry ${PN} ${PN} ${PN} "Development"
}
