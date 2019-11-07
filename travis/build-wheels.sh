#!/bin/bash
set -e -x

# Install swig
yum install -y swig

# Compile wheels
for PYBIN in /opt/python/*[23][5678]*/bin; do
    "${PYBIN}/pip" install -r /io/requirements.txt
    "${PYBIN}/python" /io/setup.py build_ext --inplace
    "${PYBIN}/pip" wheel /io/ -w wheelhouse/
done

# Bundle external shared libraries into the wheels
for whl in wheelhouse/cosmolopy*.whl; do
    auditwheel repair "$whl" --plat $PLAT -w /io/wheelhouse/
done

# Install packages and test
for PYBIN in /opt/python/*[23][5678]*/bin/; do
    "${PYBIN}/pip" install cosmolopy --no-index -f /io/wheelhouse
    "${PYBIN}/python" -c "import cosmolopy; import cosmolopy.EH.power"
done

