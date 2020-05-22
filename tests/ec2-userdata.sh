#!/bin/bash -xe

TMP=$(mktemp -d)
#trap "{ rm -rf $TMP; }" EXIT

export DEBIAN_FRONTEND=noninteractive
apt-get update \
    && apt-get upgrade -y \
    && apt-get dist-upgrade -y \
    && apt autoremove -y \
    && apt-get install -y \
        python3 \
        python3-pip \
        python3-venv \
        virtualenv \
        python3-apt \
        sudo \
        git-core

git clone https://github.com/atorrescogollo/kali-ansible.git $TMP/kali-ansible

# Prepare virtualenv & activate
virtualenv --system-site-packages -p python3 $TMP/venv
. $TMP/venv/bin/activate

# Install requirements
pip install ansible
requirementsfile="$TMP/kali-ansible/tests/requirements.txt" \
  && [ -f "$requirementsfile" ] \
     && pip3 install -r $requirementsfile

# Prepare playbook
cat << EOF > $TMP/playbook.yml
- name: 'Provide kali server'
  hosts: localhost
  become: yes
  connection: local
  roles:
    - role: $TMP/kali-ansible
      vars:
        ansible_python_interpreter: python3
EOF

# Run playbook
ansible-playbook -i localhost, $TMP/playbook.yml