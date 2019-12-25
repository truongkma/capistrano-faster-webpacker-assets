namespace :load do
  set :assets_dependencies, %w(app/assets lib/assets vendor/assets Gemfile.lock config/routes.rb)
  set :use_webpacker, true
end

Rake::Task["deploy:assets:precompile"].clear_actions
class PrecompileRequired < StandardError; end

namespace :deploy do
  namespace :assets do
    desc "Precompile assets"
    task :precompile do
      on roles(fetch(:assets_roles)) do
        within release_path do
          with rails_env: fetch(:rails_env) do
            begin
              # find latest release
              latest_release = capture(:ls, "-xr", releases_path).split[1]

              # precompile if this is the first deploy
              raise PrecompileRequired unless latest_release

              latest_release_path = releases_path.join(latest_release)

              # precompile if the previous deploy failed to finish precompiling
              execute(:ls, latest_release_path.join('assets_manifest_backup')) rescue raise(PrecompileRequired)
              fetch(:assets_dependencies).each do |dep|
                release = release_path.join(dep)
                latest = latest_release_path.join(dep)

                # skip if both directories/files do not exist
                next if [release, latest].map{|d| test "[ -e #{d} ]"}.uniq == [false]

                # execute raises if there is a diff
                execute(:diff, '-Nqr', release, latest) rescue raise(PrecompileRequired)
              end

              if fetch(:use_webpacker)
                webpacker_config = YAML.load_file(release_path("config", "webpacker.yml"))
                webpack_public_assets = "#{webpacker_config[fetch(:rails_env).to_s]['public_root_path']}/#{webpacker_config[fetch(:rails_env).to_s]['public_output_path']}"
                webpack_source_path = webpacker_config[fetch(:rails_env).to_s]["source_path"]
                execute(:diff, '-Nqr', release_path.join(webpack_source_path), latest_release_path.join(webpack_source_path)) rescue raise(PrecompileRequired)
                # Copy webpacker public/packs folder
                execute(:cp, '-r', latest_release_path.join(webpack_public_assets), release_path(webpack_public_assets).parent)
                # check that the manifest has been created correctly, if not
                execute(:ls, release_path(webpack_public_assets).join('manifest*')) rescue raise(PrecompileRequired)
              end

              info("Skipping asset precompile, no asset diff found")

              # copy over all of the assets from the last release
              # skip if assets directory is symlink
              release_asset_path = release_path.join('public', fetch(:assets_prefix))
              begin
                execute(:test, '-L', release_asset_path.to_s)
              rescue
                execute(:cp, '-r', latest_release_path.join('public', fetch(:assets_prefix)), release_asset_path.parent)
              end

              # check that the manifest has been created correctly, if not
              begin
                execute(:ls, release_asset_path.join('manifest*'))
              rescue
                begin
                  execute(:ls, release_asset_path.join('.sprockets-manifest*'))
                rescue
                  raise(PrecompileRequired)
                end
              end
            rescue PrecompileRequired
              execute(:rake, "assets:precompile")
            end
          end
        end
      end
    end
  end
end
