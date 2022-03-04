#!/bin/bash

export MIX_ENV=prod
mix deps.get --only prod
mix compile
mix assets.deploy
mix release --overwrite
rsync -av _build/prod/rel/virt/ colosseum.sudov.im:virt/
