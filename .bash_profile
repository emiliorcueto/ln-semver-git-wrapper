alias ln-status='git status'
alias ln-branch='git branch'
alias ln-branch='git merge'
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
	
	COMMIT_HASH=`git log -n 1 --pretty=format:%H`
	#echo $COMMIT_HASH

	#AFFECTED_FILES=(`git diff-tree --no-commit-id --name-only -r $COMMIT_HASH`)
	#echo $AFFECTED_FILES
	
	#make sure you dont need to pull first
	git fetch origin
	
	#stackoverflow: http://stackoverflow.com/a/16920556
	if [ "`git log --pretty=%H ...refs/heads/$BRANCH^ | head -n 1`" = "`git ls-remote origin -h refs/heads/$BRANCH |cut -f1`" ]; then   
		 echo "Branch is up-to-date.  nothing to do"
		 return 0
	else 
		
		STATUS=`git status 2>&1`
		if [[ "$STATUS" != *'working directory clean'* && "$STATUS" != *'Untracked files'* ]]
		then
			echo "You still have uncommitted files.  Push Aborted"
			return 0
		else
			if [[ "$STATUS" == *'Your branch is ahead'* ]]
			then
				# ok Go!
				if [ "$BRANCH" == "dev" ]; then                
					LAST_TAG=`git describe --abbrev=0 --tags`
	
					if [[ ! -z $LAST_TAG ]]; then
				
						OIFS=$IFS
						IFS='.' read -a VERSION <<< "$LAST_TAG"
						IFS=$OIFS
				
						NEW_REVISION=$((${VERSION[2]}+1))
						NEW_VERSION=`echo "${VERSION[0]}"."${VERSION[1]}"."$NEW_REVISION"`
				
						REMOTE_TAGS=$(git ls-remote --tags)
						
						if grep -q "$NEW_VERSION" <<< "$REMOTE_TAGS" ; then
							while true
							do
								echo "Calculating New Version #"
								echo "Press [CTRL+C] to stop.."
								
								((NEW_REVISION++))
								NEW_VERSION=`echo "${VERSION[0]}"."${VERSION[1]}"."$NEW_REVISION"`
								
								if ! grep -q "$NEW_VERSION" <<< "$REMOTE_TAGS" ; then
									echo "New Version: $NEW_VERSION"
									git tag -a "$NEW_VERSION" -m "Version: $NEW_VERSION"
									break
								fi
							done
						else 
							echo "Tagging New Version: $NEW_VERSION"
							git tag -a "$NEW_VERSION" -m "Version: $NEW_VERSION"
						fi
					else 
						echo "Could not increment version.  Please update tag manually using git tag then try ln-push again.  See git -h for help"
					fi
					
					CMD="git push $REMOTE $BRANCH --tags"
					$CMD
					
					return 1
				fi
				
				CMD="git push $REMOTE $BRANCH"
				$CMD
				
			elif [[ "$STATUS" == *'have diverged'* ]]
			then
				echo "$REMOTE/$BRANCH and your local branch: $BRANCH have diverged.  Please pull,merge with $REMOTE/$BRANCH, then try again"
				return 0
			elif [[ "$STATUS" == *'is behind'* ]]
			then
				echo "$REMOTE/$BRANCH is ahead of your local branch: $BRANCH.  Please update using ln-pull, then try again"
				return 0
			fi
		fi
	fi
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
}

