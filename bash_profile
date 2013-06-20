alias ln-status='git status'
alias ln-branch='git branch'
alias ln-stash='git stash'
alias ln-diff='git diff'
alias ln-checkout='git checkout'
alias ln-add='git add'

function ln-pull() {
	if [ -z "$2" ]; then
		BRANCH=$(git branch | grep "*" | awk '{print $2}')
	else
		BRANCH=$2
	fi

	if [ -z "$1" ]; then
		REMOTE='origin'
	else
		REMOTE=$1
	fi

	CMD="git pull $REMOTE $BRANCH"
	#echo $CMD
	$CMD  
}

function ln-push() {
	if [ -z "$2" ]; then
		BRANCH=$(git branch | grep "*" | awk '{print $2}')
	else
		BRANCH=$2
	fi

	if [ -z "$1" ]; then
		REMOTE='origin'
	else
		REMOTE=$1
	fi

	CMD="git push $REMOTE $BRANCH --tags"
	#echo $CMD
	$CMD  
}

function ln-commit() {
	if [ -z "$1" ]; then
		echo "You must specify a commit message.  Try \"ln-commit -h\" for help"
                return 0
	fi

	CMD="git commit -m "

	while test $# -gt 0; do
		case "$1" in
			-h|--help)
				echo " "
				echo "options:"
				echo "-h, --help                        show brief help"
				echo "-m, --message='<MESSAGE TEXT>'    specify a commit message"
				return 0
				;;
			-m)
				shift
				if test $# -gt 0; then
					CMD+=\""$1"\"
				fi
				shift
				;;
			--message*)
				MESSAGE = `echo $1 | sed -e 's/^[^=]*=//g'`
				CMD+=\""$1"\"
				shift
				;;
			*)
				echo "You must specify a commit message.  Try \"ln-commit -h\" for help"
				return 0
				;;
		esac
	done

	eval $CMD

        COMMIT_HASH=`git log -n 1 --pretty=format:%H`
        #echo $COMMIT_HASH

        #AFFECTED_FILES=(`git diff-tree --no-commit-id --name-only -r $COMMIT_HASH`)
        #echo $AFFECTED_FILES

        LAST_TAG=`git describe --abbrev=0 --tags`

        if [[ ! -z $LAST_TAG ]]; then

                OIFS=$IFS
                IFS='.' read -a VERSION <<< "$LAST_TAG"
                IFS=$OIFS

                NEW_REVISION=$((${VERSION[2]}+1))

                NEW_VERSION=`echo "${VERSION[0]}"."${VERSION[1]}"."$NEW_REVISION"`

                git tag -a "$NEW_VERSION" -m "Version: $NEW_VERSION"
        fi
}
