### create repos ####
./clean.sh

mkdir test_root
cd test_root
CWD=`pwd`

## remote ##
mkdir remote; cd remote

mkdir A B0 B1 C0 C1
cd $CWD/remote/C0
git init
echo "fileC0" >> fileC0
git add -A
git commit -m "commit C0 0"

cd $CWD/remote/C1
git init
echo "fileC1" >> fileC1
git add -A
git commit -m "commit C1 0"

cd $CWD/remote/B0
git init
git submodule add $CWD/remote/C0 external/C0
git submodule add $CWD/remote/C1 external/C1
echo "fileB" >> fileB
git add -A
git commit -m "commit B0 0"
cd $CWD/remote/B1
git init
git submodule add $CWD/remote/C0 external/C0
git submodule add $CWD/remote/C1 external/C1
echo "fileB" >> fileB
git add -A
git commit -m "commit B1 0"

cd $CWD/remote/A
git init
git submodule add $CWD/remote/C0 external/C0
git submodule add $CWD/remote/C1 external/C1
git submodule add $CWD/remote/B0 external/B0
git submodule add $CWD/remote/B1 external/B1
echo "fileA" >> fileA
git add -A
git commit -m "commit A 0"

cd $CWD

## local ##
echo "\n\n\n LOCAL \n\n\n"
mkdir local; cd local;
git_sclone ${CWD}/remote/A

