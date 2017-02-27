# NUcore Open

Open source version of Northwestern University Core Facility Management Software

## Quickstart

Welcome to NUcore! This guide will help you get a development environment up and running. It makes a few assumptions:

1. You write code on a Mac.
2. You have a running Oracle or MySQL instance with two brand new databases.
3. You have the following installed:
    * [Ruby 2.2](http://www.ruby-lang.org/en)
    * [Bundler](http://gembundler.com)
    * [Git](http://git-scm.com)
    * [PhantomJS] (http://phantomjs.org/)

### Spin it up

1. Download the project code from Github

    ```
    git clone git@github.com:tablexi/nucore-open.git nucore
    ```

2. Install dependencies

    ```
    cd nucore
    bundle install --without oracle
    ```

3. Configure your databases

    ```
    cp config/database.yml.mysql.template config/database.yml
    ```

    Edit the adapter, database, username, and password settings for both the development and test DBs to match your database instance

4. Create your databases

    ```
    rake db:create
    rake db:schema:load
    rake db:schema:load RAILS_ENV=test
    ```

5. Seed your development database

    ```
    rake db:seed
    rake demo:seed
    ```

6. Configure your file storage

    By default, files are stored on the local filesystem. If you wish to use
    Amazon's S3 instead, create a local settings override file such as
    `config/settings/development.local.yml` or `config/settings/production.local.yml`
    and include the following, substituting your AWS settings:

    ```
    paperclip:
      storage: fog
      fog_credentials:
        provider: AWS
        aws_access_key_id: YOUR_S3_KEY_GOES_HERE
        aws_secret_access_key: YOUR_S3_SECRET_KEY_GOES_HERE
      fog_directory: YOUR_S3_BUCKET_NAME_GOES_HERE
      fog_public: false
      path: ":class/:attachment/:id_partition/:style/:safe_filename"
    ```

7. Start your server

    ```
    bin/rails s
    ```

8. Log in

    Visit http://localhost:3000

    `demo:seed` creates several users with various permissions. All users have the default password of `password`

    | Email/username     | Role |
    | ------------------ | ---- |
    | admin@example.com  | Admin|
    | ppi123@example.com | PI   |
    | sst123@example.com | Normal User |
    | ast123@example.com | Facility Staff |
    | ddi123@example.com | Facility Director |

9. Play around! You're running NUcore!

10. Run `delayed_job` to support in-browser email previews.

    Run delayed jobs indefinitely in the background:
    ```
    ./script/delayed_job start
    ```

    Or run delayed jobs once for one-off jobs:
    ```
    ./script/delayed_job run
    ```


### Test it

NUcore uses [Rspec](http://rspec.info) to run tests. Try any of the following from NUcore's root directory.

* To run all tests (this will take awhile!)
    rake spec

* To run just the model tests
    rake spec:models

* To run just the controller tests
    rake spec:controllers

## Chart String Validation

Northwestern has complex rules around what makes a chart string valid. See the `nucs` engine for the code,
and the following documents for details.

* [Chart of Accounts Quick Reference](doc/chartstrings/ChartOfAccountsQuickRef.pdf)
* [Validation Rules (V9)](doc/chartstrings/Validating Chart Strings.V9.pdf)

## Optional Modules

The following modules are provided as optional features via
[Rails engines](http://guides.rubyonrails.org/engines.html). These are enabled
by adding the appropriate engine to your Gemfile (all are on by default). They
exist in the `vendor/engines` directory.

* Accept Credit Cards & Purchase Orders (c2po)
* Connect to Dataprobe Power Relays (dataprobe)
* Link orders together as a Project (projects)
* [Sanger Sequencing order form and well plate management](vendor/engines/sanger_sequencing/README.md)
* [Split charges between different accounts](vendor/engines/split_accounts/README.md)

## Learn more

There are valuable resources in the NUcore's doc directory.

* Want to conform to the project's established coding standards? [**See coding_standards.md**](doc/coding_standards.md)

* Want to know more about the instrument pricing model? [**See instrument_pricing.md**](doc/instrument_pricing.md)

* Need to move changes between nucore-open and your fork? [**See HOWTO_forks.txt**](doc/HOWTO_forks.md)

* Need help getting Oracle running on your Mac? [**See HOWTO_oracle.txt**](doc/HOWTO_oracle.txt)

* Want to authenticate users against your institution's LDAP server? [**See HOWTO_ldap.txt**](doc/HOWTO_ldap.md)

* Need to use a 3rd party service with your NUcore? [**See HOWTO_external_services.txt**](doc/HOWTO_external_services.md)

* Need to asynchronously monitor some aspect of NUcore? [**See HOWTO_daemons.txt**](doc/HOWTO_daemons.txt)
