#!/bin/bash
#
# Selects records that mention Sylvilagus floridanus (Eastern cottontail) as found in a specific version of the GBIF, iDigBio, BioCASe corpus. For context, see https://discourse.gbif.org/t/when-does-evidence-of-impact-become-too-onerous-to-track/4639/11 as accessed on 2024-10-10.  
#
# usage:
#
#   ./find-the-bunnies.sh
#
# If you'd like to find something other than bunnies, you can provide a version of the GBIF, iDigBio, BioCASe corpus (or any other corpus containing DwC-A) along with the scientific name of the organism you'd like to find:
#
#   ./find-the-bunnies.sh hash://sha256/37bdd8ddb12df4ee02978ca59b695afd651f94398c0fe2e1f8b182849a876bb2 "Peromyscus megalops"
#
# to find records associated with Peromyscus megalops (Brown deermouse) in version starting ending with content id "[...]6bb2"
#
# example of a starting point (version) 
# Poelen, J. H. (2023). A biodiversity dataset graph: GBIF, iDigBio, BioCASe hash://sha256/450deb8ed9092ac9b2f0f31d3dcf4e2b9be003c460df63dd6463d252bff37b55 hash://md5/898a9c02bedccaea5434ee4c6d64b7a2 (0.0.4) [Data set]. Zenodo. https://doi.org/10.5281/zenodo.7651831
# Or list of other starting points are found here: https://linker.bio/#use-case-3-studying-pine-pests-caused-by-weevils-curculionoidea
#
# On 2024-10-10, the first 2 records were produced were, in xtab format:
# 
# scientificName Sylvilagus floridanus
# eventDate      2006-04-23
# wasDerivedFrom https://linker.bio/line:zip:hash://sha256/69c839dc05a1b22d2e1aac1c84dec1cfd7af8425479053c74122e54998a1ddc2!/occurrence.txt!/L1657
# relation       partOf
# versionAnchor  https://linker.bio/hash://sha256/37bdd8ddb12df4ee02978ca59b695afd651f94398c0fe2e1f8b182849a876bb2
#
# scientificName Sylvilagus floridanus
# eventDate      2013-01-20
# wasDerivedFrom https://linker.bio/line:zip:hash://sha256/f42125910d1f4c7bd384dc005531b8089935a86ace4aca16cf9b8c36bfed4c1e!/occurrence.txt!/L525003
# relation       partOf
# versionAnchor  https://linker.bio/hash://sha256/37bdd8ddb12df4ee02978ca59b695afd651f94398c0fe2e1f8b182849a876bb2
#

VERSION_ANCHOR=${1:-"hash://sha256/37bdd8ddb12df4ee02978ca59b695afd651f94398c0fe2e1f8b182849a876bb2"}
REMOTES="https://linker.bio"
SCIENTIFIC_NAME="${2:-Sylvilagus floridanus}"
PRESTON_OPTS="--no-cache --remotes ${REMOTES}"

set -xe

preston cat ${PRESTON_OPTS} ${VERSION_ANCHOR}\
 | grep -E "(application/dwca|hasVersion)"\
 | grep --after 1 "application/dwca"\
 | preston dwc-stream ${PRESTON_OPTS}\
 | jq --raw-output -c --arg versionAnchor "${VERSION_ANCHOR}" --arg scientificName "${SCIENTIFIC_NAME}" 'select(.["http://rs.tdwg.org/dwc/terms/scientificName"] == $scientificName) | { "scientificName": .["http://rs.tdwg.org/dwc/terms/scientificName"], "eventDate": .["http://rs.tdwg.org/dwc/terms/eventDate"], "wasDerivedFrom": .["http://www.w3.org/ns/prov#wasDerivedFrom"], "relation": "partOf", "versionAnchor": $versionAnchor }'
