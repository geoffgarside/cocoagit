# Test PACK files for cocoagit

## Generating pack/idx files for testing

The pack file has the following properties:

- all objects for commits 1 -> tag 0.2.5 (85f6ab)
- objects with offsets above 300,000 are stored as extended 64-bit offsets (for testing purposes)
- v2 pack and v2 index files

for delta-ofs pack files:

    git-rev-list --objects 85f6ab303f8f6601377ce2d8ebcf186c4b5d7d68 | git-pack-objects --no-reuse-object --delta-base-offset --index-version=2,300000 cg-0.2.5-deltaofs

for delta-ref pack files:

    git-rev-list --objects 85f6ab303f8f6601377ce2d8ebcf186c4b5d7d68 | git-pack-objects --no-reuse-object --index-version=2,300000 cg-0.2.5-deltaref
