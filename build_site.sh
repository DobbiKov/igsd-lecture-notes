myst build --html
rm -rf docs/
mkdir docs/
cp -r ./_build/html/* docs/
