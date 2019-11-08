#!/bin/bash
set -e -x

# Install swig
yum install -y swig
yum info swig
echo $(which swig)
yum localinstall -y http://springdale.math.ias.edu/data/puias/computational/6/x86_64//swig3012-3.0.12-3.sdl6.x86_64.rpm
yum list installed
yum info swig3012
rpm -ql swig
rpm -ql swig3012
echo $(which swig3012.x86_64)
printf '%s\n' ${PATH//:/\/* } | grep swig
ln $(which swig3012) swig --symbolic

# Compile wheels
#cd io
#for PYBIN in ../opt/python/*[23][5678]*/bin; do
#    "${PYBIN}/pip" install -r requirements.txt
#    "${PYBIN}/python" setup.py build_ext --inplace
#    "${PYBIN}/pip" wheel . -w ../wheelhouse/
#done
#cd ..
for PYBIN in /opt/python/*[23][567]*/bin; do
    "${PYBIN}/pip" install -r /io/requirements.txt
    "${PYBIN}/pip" wheel /io/ -w wheelhouse/
done

# Bundle external shared libraries into the wheels
for whl in wheelhouse/cosmolopy*.whl; do
    auditwheel repair "$whl" --plat $PLAT -w /io/wheelhouse/
done

# Install packages and test
for PYBIN in /opt/python/*[23][567]*/bin/; do
    "${PYBIN}/pip" install cosmolopy --no-index -f /io/wheelhouse
    "${PYBIN}/python" -c "import cosmolopy; import cosmolopy.EH.power"
done

