# Rubocop usage
Rubocop is used as code style checker and code formatter. It is used with setting taken from [PDK 1.18.0](https://github.com/puppetlabs/pdk/tree/v1.18.0). See `.rubocop.yml` for details.

### with Ruby 2.1.9
To run rubocop on this outdated version of Ruby you need to install specific old versions of Rubocop:
- rubocop v0.49.1
- rubocop-i18n v1.2.0
- rubocop-rspec v1.16.0

If you use Rubygems for setup you can run these commands to install:
```bash
gem install rubocop -v 0.49.1
gem install rubocop-i18n -v 1.2.0
gem install rubocop-rspec -v 1.16.0
```
