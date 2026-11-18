# osm-govan-static

A static, read-only Wikibase (GitHub Pages) for OpenStreetMap elements: the features within 120 m of Govan Old in Glasgow (church, churchyard, historic and archaeological objects, the museum The Govan Stones).
It is built with [wikibase-static](https://github.com/n4o-rse/wikibase-static) and follows the site
[osm-benchmarks-static](https://github.com/n4o-rse/osm-benchmarks-static), whose model it takes over unchanged.

Each OSM element becomes one item with one QID, as OSM itself knows only one ID per element. The
element's version history is tracked as statements on that item, and every item is anchored on
a CIDOC CRM class: `crm:E18 Physical Thing` (proposal, see PRIMER.md). The geometry of each version is kept as WKT, so the model also carries ways and relations.

**State (S1, S2):** the skeleton and the model (the class “Govan Old feature”, the fourteen properties of the benchmarks site) are in place; there are no data yet. The first harvest is step S4 (a handful of elements), after a change in the package (`wikibase-static`, PRIMER.md step S3). The work plan, the decisions made so far and the steps ahead are in [`PRIMER.md`](PRIMER.md) (German).

## Build

Needs Python 3.10 or later. In a Windows `cmd` window, in this folder:

    pip install -r requirements.txt && python main.py --strict

`python main.py --list` shows the steps. `python main.py import-osm --probe` sends one Overpass request and writes nothing (it asks for the selection `govan` by itself).
`update.cmd` installs the current `wikibase-static` again, builds with `--strict`, and commits and pushes
only if something changed.

## Related repositories

- [`Research-Squirrel-Engineers/osm2lod`](https://github.com/Research-Squirrel-Engineers/osm2lod): the prototype that exports OSM data via Overpass into RDF and a Wikibase.
- [`n4o-rse/wikibase-static`](https://github.com/n4o-rse/wikibase-static): the package that turns CSV tables into the static Wikibase pages, RDF and SPARQL page.
- [`n4o-rse/osm-benchmarks-static`](https://github.com/n4o-rse/osm-benchmarks-static): the sibling site for the benchmarks, from which the model is taken.

## Licence and attribution

The code of this repository is under the [MIT licence](LICENSE).

The data are derived from OpenStreetMap: © OpenStreetMap contributors, available under the
[Open Database Licence (ODbL) 1.0](https://opendatacommons.org/licenses/odbl/1-0/).
Every page of the site carries that notice (`license` in `site.yaml`).
