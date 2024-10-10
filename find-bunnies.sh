#!/bin/bash
#
# selects records that mention Sylvilagus floridanus (Eastern cottontail) as found in a specific version of the GBIF, iDigBio, BioCASe corpus. 
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

VERSION_ANCHOR=${1:-"hash://sha256/37bdd8ddb12df4ee02978ca59b695afd651f94398c0fe2e1f8b182849a876bb2"}
REMOTES="https://linker.bio"
SCIENTIFIC_NAME="${2:-Sylvilagus floridanus}"
PRESTON_OPTS="--no-cache --remotes ${REMOTES}"

set -xe

preston cat ${PRESTON_OPTS} ${VERSION_ANCHOR}\
 | grep -E "(application/dwca|hasVersion)"\
 | grep --after 1 "application/dwca"\
 | preston dwc-stream ${PRESTON_OPTS}\
 | jq -c --arg scientificName "${SCIENTIFIC_NAME}" 'select(.["http://rs.tdwg.org/dwc/terms/scientificName"] == $scientificName)'
