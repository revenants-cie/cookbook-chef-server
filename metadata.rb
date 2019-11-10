name 'chef-server'
maintainer 'Revenants CIE, LLC'
maintainer_email 'dev@@revenants.net'
license 'All Rights Reserved'
description 'Installs/Configures chef-server'
long_description 'Installs/Configures chef-server'
version '0.1.0'
chef_version '>= 13.0'
supports 'redhat'

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
issues_url 'https://github.com/revenants-cie/cookbook-chef-server/issues'

# The `source_url` points to the development repository for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
source_url 'https://github.com/revenants-cie/cookbook-chef-server'

depends 'poise-python', '~> 1.7.0'
depends 'logrotate', '~> 2.2.2'
