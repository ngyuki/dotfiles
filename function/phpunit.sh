################################################################################
### phpunit

function phpunit
{
	local phpunit=(command phpunit)
	local root="${PWD}"

	while [ -n "${root}" ]; do
		if [ -x "${root}/vendor/bin/phpunit" ]; then
			phpunit=("${root}/vendor/bin/phpunit")
			break
		fi
		root="${root%/*}"
	done

	local configuration=()
	local root="${PWD}"

	while [ -n "${root}" ]; do
		local dir xml
		for dir in "/tests/" "/" ; do
			for xml in "phpunit.xml.dist" "phpunit.xml"; do
				if [ -e "${root}${dir}${xml}" ]; then
					configuration=("--configuration=${root}${dir}")
					break 3
				fi
			done
		done
		root="${root%/*}"
	done

	"${phpunit[@]}" "${configuration[@]}" --colors "$@"
	return ${PIPESTATUS[0]}
}
