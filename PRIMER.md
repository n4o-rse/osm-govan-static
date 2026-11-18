# PRIMER — osm-govan-static

Arbeitsplan für `n4o-rse/osm-govan-static` (Repo angelegt 2026-11-18). Wird zu Beginn jedes Chats hochgeladen (Bundle, siehe A5) und am Ende zurückgeschrieben. Stand: 2026-11-18 (S0 bis S2 eingespielt, S4 Rohdaten geerntet, S5 geprüft, S6 gebaut; S3 offen im Paket, S7 danach).

Sprache: dieses Dokument ist deutsch, alles andere im Repo (Code, Kommentare, README) ist britisches Englisch.

---

## Teil A — Immer gültig

### A1 Ausgangslage

| Repo | Rolle | Stand |
|---|---|---|
| `Research-Squirrel-Engineers/osm2lod` | Prototyp: Overpass-Abfrage je Export-Typ, CSV, TTL und QuickStatements je Lauf; liefert für Govan nichts (Abfrage aus Overpass Turbo) | vorhanden, wird nicht umgebaut |
| `n4o-rse/wikibase-static` | Paket (v0.28.0): CSV (vier Tabellen) → Wikibase-JSON → Seiten, RDF, SPARQL; Verb `import-osm`; BeaverBridge-Design mit hell/dunkel | vorhanden; Änderungen für dieses Repo: S3 |
| `n4o-rse/osm-benchmarks-static` | Vorbild: Site-Repo mit den Benchmarks (23 Nodes, live); Modell, Skeleton, Workflow, Abfragen werden von dort übernommen | vorhanden, S0 bis S8 erledigt |
| `n4o-rse/osm-govan-static` | dieses Repo | neu, S0 bis S2 gebaut |
| `n4o-rse/osm-holywells-static`, `osm-ogham-static`, `osm-sisal-static` | Schwester-Sites mit gleichem Modell und gleichem Stand (Skeleton und Modell, Paket v0.26.1, kein Harvest) | angelegt 2026-11-01 |
| `n4o-rse/wd-govanstones-static` | Wikidata-Site zu denselben Steinen (Präfix `gvs`, live) | vorhanden |

Nicht neu zu bauen: das Modell (P100 bis P113), `import-osm`, Seiten, RDF, SPARQL-Seite, `check-crm` (kommen aus `osm-benchmarks-static` und dem Paket).

**Befunde** (geprüft 2026-11-01, soweit nicht anders gesagt):

1. **Quelle der Abfrage.** Anders als bei Holy Wells, Ogham und SISAL stammt die Abfrage **nicht aus osm2lod**, sondern aus Overpass Turbo (Screenshot von Flo, 2026-11-18): neun Teilbedingungen im Umkreis von 120 m um 55.864725, −4.313125 (die Kirche mit dem Museum „The Govan Stones“, Glasgow):

   ```
   [out:json][timeout:180];
   (
     // Church building and place of worship
     nwr(around:120,55.864725,-4.313125)["building"="church"];
     nwr(around:120,55.864725,-4.313125)["amenity"="place_of_worship"];
   
     // Cemetery or churchyard
     nwr(around:120,55.864725,-4.313125)["landuse"="cemetery"];
     nwr(around:120,55.864725,-4.313125)["amenity"="grave_yard"];
   
     // Historic and archaeological objects, among them the hogbacks
     nwr(around:120,55.864725,-4.313125)["historic"];
     nwr(around:120,55.864725,-4.313125)["archaeological_site"];
     nwr(around:120,55.864725,-4.313125)["collection"="yes"];
   
     // Museum: The Govan Stones
     nwr(around:120,55.864725,-4.313125)["tourism"="museum"];
     nwr(around:120,55.864725,-4.313125)["museum"];
   );
   out meta;
   ```

   Hier gespeichert unter `data/seeds/overpass-govan.overpassql`; geändert nur `out geom;` → `out meta;` (das Paket baut die Geometrie selbst), das Zeitlimit 30 → 180 s (wie bei den Benchmarks) und die Kommentare ins Englische.
2. **Umfang.** Overpass Turbo meldet im Screenshot „Loaded – nodes: 6, ways: 1, relations: 1“, also 8 Elemente (Stand 2026-11-18; Zahl nicht geprüft, Overpass ist aus der Sandbox nicht erreichbar). Auf der Karte: ein Gebäude (Way) und eine Friedhofsfläche in zwei Teilen (wohl die Relation); die Nodes sind das Museum, das Kreuz und weitere Punkte. Damit hat diese Site als einzige **einen Way und eine Relation** unter den kleinen Mengen: der Echttest der Geometrie (S5) ist hier gut machbar.
3. **Tag-Bedingung, Lücke im Paket.** Das Paket braucht je Auswahl eine Tag-Bedingung für den Eintrittsmarker und **verknüpft alle Zeilen mit UND** (`step_import_osm.py`, `read_selection`; ein leerer Wert heißt „Schlüssel muss existieren“). Die Abfrage ist aber ein **ODER** aus neun Bedingungen. Es gibt keine Bedingung, die für alle Elemente gilt. **Platzhalter** in `data/seeds/govan.csv`: `name` muss existieren. Folge, solange das so bleibt: ein Element ohne `name` wird als „nie in der Auswahl“ gemeldet und bekommt keinen Eintrittsmarker; der Marker zeigt bei den anderen die erste Version mit `name`, nicht die erste Version in der Abfrage. **Vor dem ersten Harvest klären** (S3, Teil D).
4. **Paket v0.28.0, Grenzen** (im Quelltext geprüft): (a) eine Klasse und eine Auswahl je Site; (b) die Beschreibungswörter sind fest eingebaut („Benchmark“/„Höhenmarke“ als Rückfall, Tabelle `THINGS`): Objekte würden als „Benchmark (OpenStreetMap node …)“ beschrieben (S3); (c) `crm:E18_Physical_Thing` ist in `crm.py` bekannt (Oberklasse `crm:E72_Legal_Object`), hier braucht das Paket für das CRM nichts. Der Auswahlname ist `benchmarks`, solange `--selection` fehlt; `main.py` hängt `--selection govan` selbst an.
5. **Umfang des Harvests.** 8 Elemente: eine Overpass-Anfrage, höchstens 8 History-Anfragen, dazu die Stützpunkte von Way und Relation (`data/raw/osm/members/`, `--member-limit`); ein Lauf genügt. Overpass und die OSM-API sind aus der Sandbox nicht erreichbar (am 2026-11-18 erneut geprüft, 403 des Proxys); der Harvest läuft bei Flo.
6. **Verwandt.** `wd-govanstones-static` (Wikidata, Präfix `gvs`, auf GitHub Pages online) beschreibt dieselben Steine aus Wikidata; diese OSM-Site beschreibt die Kartierung vor Ort. Eine Verknüpfung (Wikidata-QID aus dem Tag `wikidata` eines OSM-Elements) kommt über P-Property des Modells; ein `owl:sameAs` auf OSM bleibt ausgeschlossen (A4).
7. **Skeleton ohne Daten** (geprüft 2026-11-18 mit `wikibase-static` v0.28.0): `python main.py --strict` läuft mit den Modelldateien (4 Klassen: Q1 bis Q3 und Q100; 24 Properties, 60 Statements) dreimal mit Exit-Code 0 durch; nach dem Einchecken von `data/derived/`, `dist/` und `docs/` ist `git status` leer. `check-crm` meldet 0 Verstöße, `check_attribution.py` findet „OpenStreetMap contributors“ in 63 Dateien. Ohne `queries.yaml` scheitert `--strict` an der Standardabfrage `coordinates` (keine Zeilen, WARN), deshalb liegt eine vorläufige `queries.yaml` (Standardsatz von v0.28.0 ohne `coordinates`) im Repo, die mit dem ersten Harvest gelöscht wird. Ohne Logo baut die Site sauber (kein Eintrag `logo` in `site.yaml`).
8. **Erstharvest und Rohdaten (S4, geerntet 2026-11-18, bei Flo).** Overpass-Stand 2026-11-18: 8 Elemente (6 Nodes, 1 Way, 1 Relation), 28 Version-Statements, 7 mit `name`, 7 mit `wikidata`. Die Elemente: das Museum „The Govan Stones“ (Node), fünf Hogbacks „Govan Stone 2“ bis „Govan Stone 6“ (Nodes, `historic=hogback`), die Kirche „Govan Old Parish Church“ (Way 49859412, Version 7, 22 Geometriestände) und der Friedhof (Relation 19260105, `amenity=grave_yard`, ohne Namen, MULTIPOLYGON). Sieben von acht tragen ein `wikidata`-Tag (alle außer dem Friedhof): die Brücke zu `wd-govanstones-static`. Die Relation hat wegen des Platzhalters der Tag-Bedingung (Befund 3) keinen Eintrittsmarker. Der Echttest der Geometrie ist bestanden (Way und Relation mit WKT-Verlauf, GeoSPARQL im RDF). Die Rohdaten liegen committet unter `data/raw/osm/` (Commit 1863b34); der Import in die Tabellen läuft offline (`python main.py import-osm --offline`, ersetzt alle Zeilen mit `origin=osm`) und wartet auf S3. Das zweite Mal `import-osm` stellt nur noch die Overpass-Anfrage.

---

### A2 Zielbild

Eine statische Wikibase auf GitHub Pages für die OSM-Elemente rund um Govan Old in Glasgow, mit Versionshistorie und CIDOC-CRM-Verankerung, gebaut wie `osm-benchmarks-static`.

```
 data/seeds/overpass-govan.overpassql + data/seeds/govan.csv     (Abfrage aus Overpass Turbo, Tag-Bedingung)
         │
         │ import-osm   (Verb mit Netz, nie im Standardlauf)
         ▼
 Overpass  ──►  data/raw/osm/overpass/<name>.json        Elemente und aktuelle Versionen
 OSM API   ──►  data/raw/osm/history/<type>_<id>.json   volle Historie (nur bei Versionsabweichung)
         │         data/raw/osm/members/                 Historien der Stützpunkte von Ways
         │ import-osm --offline  +  data/csv/mapping/osm-properties.csv
         ▼
 data/csv/  entities.csv  statements.csv  qualifiers.csv  references.csv  idmap.csv     data/crm.csv  (Govan Old feature → crm:E18)
         │ from-csv → load → build → search → rdf → sparql
         ▼
 docs/  (GitHub Pages: Seiten, Karte, Suche, SPARQL)      dist/*.ttl  (DCAT 3, GeoSPARQL, CIDOC CRM)
```

Eine QID je OSM-Element, die Versionen als Statements daran; das Beispiel mit den Statements und Qualifiern steht in A2 von `osm-benchmarks-static`.

Die Ergebnisse müssen diese Eigenschaften haben, jede ist prüfbar:

1. Jedes Element hat genau eine QID; es gibt keine Versions-Items.
2. Zahl der OSM-Version-Statements je Element = Zahl der Versionen in der API-History (Versionen ohne Position, also Löschungen, ausgenommen).
3. Jede QID ist über `data/crm.csv` auf eine CRM-Klasse verankert; `check-crm` meldet keinen Verstoß.
4. Das RDF enthält kein `owl:sameAs` auf OpenStreetMap; die Statement- und Wert-IRIs sind reine Bezeichner im eigenen Namensraum.
5. Zweimal laufen lassen ändert nichts (`git status` leer); ein zweiter Harvest ohne Änderung bei OSM stellt nur die Overpass-Anfrage.


### A3 Querschnittsregeln

- Rohdaten liegen unter `data/raw/`, unverändert wie erhalten, nicht von Hand ändern. Was ein Skript daraus macht, geht nach `data/csv/`, `data/derived/`, `dist/` oder `docs/`.
- Wiederverwendung heißt kopieren, nicht referenzieren. Das Modell (P100 bis P113) ist aus `osm-benchmarks-static` kopiert und bleibt dort wie hier gleich; Abweichungen stehen in A4.
- **Keine Uhr im Output.** Kein Generator ruft `datetime.now()` auf. Zeitangaben stammen aus den Quelldaten (Zeitstempel der OSM-Versionen) oder aus `RELEASE_DATE`.
- **Zeilenenden LF** (`.gitattributes`: `* text=auto eol=lf`).
- **Zweimal laufen lassen, `git status` bleibt sauber.**
- **Netzwerk nur im Verb `import-osm`.** Alles andere läuft offline gegen `data/raw/`; das Verb gehört nie zum Standardlauf.
- **Höflicher Harvest.** Ehrlicher User-Agent mit Kontaktadresse (`--contact`), mindestens eine Sekunde Pause zwischen Requests an die OSM API, `Retry-After` beachten, Overpass nur mit einer Abfrage zur Zeit; die OSM-Nutzungsregeln gelten.
- **Die Seiten zeigen, was die Quelle sagt.** Werte werden formatiert, nicht repariert.
- **Lizenz und Namensnennung.** Die Daten sind OpenStreetMap-Daten (ODbL 1.0, „© OpenStreetMap contributors“); der Hinweis steht auf jeder Seite und im RDF.
- Befehle für Windows `cmd`, jeder in **einer** Zeile, zusammengehörige Befehle mit `&&` verkettet.
- Mermaid-Diagramme nutzen das feste Farbschema der Familie (Subject/Object grau, RealObject dunkelgrün, Class dunkelorange, Term dunkelviolett, OWL weiß, PropMeta amber).

### A4 Beschlusslage

| Frage | Beschluss | seit |
|---|---|---|
| Zweck | Statische Wikibase (GitHub Pages) für die OSM-Elemente im Umkreis von 120 m um Govan Old, Glasgow (Kirche, Kirchhof, historische und archäologische Objekte, Museum „The Govan Stones“); gleiche Idee wie die Benchmarks | 2026-11-18 |
| Repo-Zuschnitt | Ein Repo je Typ; dies ist das fünfte Site-Repo mit OSM-Quelle (`osm-benchmarks-static`, `osm-holywells-static`, `osm-ogham-static`, `osm-sisal-static`, `osm-govan-static`) | 2026-11-18 |
| Repo-Name und Ort | `n4o-rse/osm-govan-static` (leeres Repo angelegt, 2026-11-18), lokal `C:\git\osm-govan-static` | 2026-11-18 |
| Klasse, ID | **Eine** Klasse Q100 „Govan Old feature“ (de „Objekt bei Govan Old“), `subclass of` Q3; Properties P100 bis P113 wie bei den Benchmarks; Rolle `class_benchmark` = Q100. Die OSM-Tags stehen je Element als P113, daran unterscheidet man Kirche, Friedhof und Museum | 2026-11-18 |
| CRM-Anker | `crm:E18` Physical Thing über `data/crm.csv` (gemeinsamer Nenner der gemischten Menge); feinere Klassen (Kirche, Friedhof, Museum) bräuchten mehrere Klassen im Paket, Teil D | 2026-11-18 |
| Abfrage | Unverändert aus Overpass Turbo übernommen (Umkreis 120 m, neun Teilbedingungen); wenn mehr erfasst werden soll, sagt Flo Bescheid | 2026-11-18 |
| Auswahl | Name `govan`; Dateien `data/seeds/govan.csv` (Tag-Bedingung, **Platzhalter** `name`, siehe Befund 3) und `data/seeds/overpass-govan.overpassql` | 2026-11-18 |
| Auswahlname | `main.py` hängt bei `import-osm` `--selection govan` an, wenn es fehlt (wie bei den drei Schwester-Sites) | 2026-11-18 |
| Logo | Zeichnung des Govan-Sarkophags in der alten Kirche (`assets/logo.png`), von Florian Thiery, mit ChatGPT erzeugt, CC BY 4.0 (bestätigt 2026-11-18) | 2026-11-18 |
| Modell | Wie `osm-benchmarks-static`, **1:1**: eine QID je OSM-Element, Versionen als Statements, Eintrittsmarker, Geometrie-Verlauf als WKT, Tags nur aktuell als `key=value`; Properties P100 bis P113 mit denselben IDs, Namen und Datentypen; Rolle → ID in `data/csv/mapping/osm-properties.csv`. Alle übrigen Beschlüsse der A4 dort gelten hier unverändert | 2026-11-18 |
| Lizenz | ODbL 1.0 mit „© OpenStreetMap contributors“ in `site.yaml` (`license`); der Code unter MIT | 2026-11-18 |
| URIs | Eigener Namensraum im github.io-Raum des Repos (`rdf_base`), Präfixfamilie `ogs` (`ogs:`, `ogst:`, …; Vorschlag, Schwestern: `ohs`, `oos`, `oss`); kein `owl:sameAs` und kein `skos:exactMatch` auf OSM | Vorschlag 2026-11-18 |
| Skeleton | Wie die Schwester-Sites auf dem Stand vom 2026-11-18: dünnes `main.py`, `site.yaml`, `requirements.txt` auf `wikibase-static` v0.28.0, `update.cmd`, `check_attribution.py`, Workflow-Aufrufer `site.yml` mit `deploy: false` und `update.yml` (Update-PR bei neuer Paketversion) | 2026-11-18 |

### A5 Was in welchem Chat hochgeladen wird

Ein Bundle statt Einzeldateien. Mitnehmen: `PRIMER.md`, Quelltexte, kleine Daten (`data/raw/osm/`). Nicht mitnehmen: `.git/`, `.venv/`, `config.local.*`, große erzeugte Dateien.

```cmd
robocopy . ..\osm-govan-static-bundle /E /XD .git .venv __pycache__ build /XF config.local.ini config.local.json >nul & powershell -NoProfile -Command "Compress-Archive -Path ..\osm-govan-static-bundle\* -DestinationPath ..\osm-govan-static-bundle.zip -Force"
```

(robocopy meldet Erfolg mit Exit-Code unter 8, das ist normal.) Das Paket `wikibase-static`, `osm-benchmarks-static` und die Schwester-Sites klont Claude selbst von GitHub. Ein Chat im Paket-Repo (S3) bekommt dessen PRIMER und dessen Bundle.

### A6 IRI-Landkarte

Alles `geplant`, bis die erste Veröffentlichung die Basis festlegt. Vorschlag: `rdf_base` = `https://n4o-rse.github.io/osm-govan-static`, `rdf_prefix` = `ogs`.

| Pfad | Inhalt | Ziel des Redirects | Status |
|---|---|---|---|
| `<base>/entity/<ID>` | Konzept-URI eines Elements (Weiterleitungsseite) | – | geplant |
| `docs/ttl/<ID>.ttl`, `docs/json/<ID>.json` | ein Element als Turtle bzw. JSON | – | geplant |
| `docs/downloads/<host>.ttl` | RDF aller Entitäten, beschrieben mit DCAT 3 | – | geplant |
| `docs/sparql.html`, `docs/query.html` | Query-Seite und Editor | – | geplant |
| w3id-Präfix | offen, wie im Paket vorerst keines | offen | geplant |

---

## Teil B — Schrittübersicht

| ID | Schritt | Repo | hängt ab von | Status |
|---|---|---|---|---|
| S0 | Festlegungen, Abfrage aus Overpass Turbo, Befunde | osm-govan-static | – | erledigt 2026-11-18 |
| S1 | Skeleton: Layout, `main.py`, `site.yaml`, `requirements.txt`, Lizenz, Citation, Workflow-Aufrufer, `update.yml`, `update.cmd` (Logo kommt mit dem Patch vom 2026-11-18) | osm-govan-static | S0 | erledigt 2026-11-18 (Commit 1608896) |
| S2 | Modell: Klasse, Properties P100 bis P113, `data/crm.csv`, Mapping-Datei, Seeds | osm-govan-static | S1 | erledigt 2026-11-18 (Commit 1608896) |
| S3 | Paket: Beschreibungswörter je Klasse statt der festen Tabelle; ODER-Bedingungen für den Eintrittsmarker (Befund 3); gemeinsam für holywells, ogham, sisal und govan | wikibase-static | S2 | offen |
| S4 | Erstharvest: 8 Elemente (Stand Screenshot), Overpass, Historien, Import, Seiten, RDF, `check-crm` | osm-govan-static | S3 | Rohdaten erledigt 2026-11-18 (Commit 1863b34); Import wartet auf S3 |
| S5 | Echttest der Geometrie an dem Way und der Relation (der zurückgestellte S6-Test der Benchmarks) | osm-govan-static | S4 | erledigt 2026-11-18 (Geometrie getestet, Befund 8) |
| S6 | Standardabfragen (`queries.yaml`): Versionen je Element, Eintrittsversion, Wikidata-Verknüpfungen (Verbindung zu `wd-govanstones-static`) | osm-govan-static | S4 | gebaut 2026-11-18 (Patch) |
| S7 | Pages-Workflow scharf (`deploy` an, `check_attribution.py`), ODbL-Hinweis, CI mit `--strict` zweimal | osm-govan-static | S4 | offen |

S1 und S2 sind in einem Patch. S3 gilt gleichzeitig für die vier neuen Site-Repos und ist ein Chat im Paket-Repo; der Harvest (S4) sollte erst danach committet werden (falsche Beschreibungen, falscher Eintrittsmarker). Flo wartet mit S3, weil sich im Paket durch die Wikidata-Sites noch etwas ändern kann.

---

## Teil C — Die Schritte

### S1 und S2 — Skeleton und Modell

**Ziel:** Ein Site-Repo auf dem Stand der Schwester-Sites, das mit `python main.py` ohne Daten sauber durchläuft und das Modell enthält.

**Uploads:** keine; Claude klont `osm-ogham-static` (Vorlage) und das Paket selbst.

Inhalt: Dateien wie bei `osm-ogham-static` (Stand 2026-11-18); neu sind die Klasse Q100 in `data/csv/entities.csv`, eine Zeile in `data/crm.csv`, `data/seeds/govan.csv` und `data/seeds/overpass-govan.overpassql`. `main.py` setzt bei `import-osm` die Auswahl `govan`. Der Workflow-Aufrufer hat `deploy: false` und prüft nur `python main.py --strict`; `check_attribution.py` ist da, läuft aber erst mit S7. Die `queries.yaml` ist vorläufig (Standardabfragen ohne `coordinates`) und wird mit dem ersten Harvest gelöscht.

**Abnahme:** `python main.py --list` nennt die Schritte; `python main.py --strict` läuft ohne Daten durch; zwei Läufe hintereinander, `git status --porcelain` leer; `python main.py --strict check-crm` ohne Verstoß.

### Erledigt 2026-11-18 (S1, S2)

Gebaut auf dem Stand von `osm-ogham-static` (2026-11-18): `main.py`, `requirements.txt` auf v0.28.0, `site.yaml`, `LICENSE`, `CITATION.cff`, `update.cmd`, `check_attribution.py`, `.github/workflows/site.yml` (`deploy: false`) und `update.yml`, `README.md`, das Modell (`data/csv/`, `data/crm.csv`, `data/csv/mapping/osm-properties.csv`), die Seeds (`data/seeds/`) und die vorläufige `queries.yaml`. Abnahme in einer frischen Kopie mit v0.28.0: `--list` nennt neun Einträge, `--strict` dreimal mit Exit-Code 0, `git status` leer, `check-crm` 0 Verstöße, `check_attribution.py` grün; `main.py` reicht `--selection govan` an `import-osm` weiter (geprüft ohne Netz). Die Properties P100 bis P113 sind bis auf den Beispieltext in P109 gleich denen der Benchmarks. Nicht geprüft: der Lauf der Workflows auf GitHub, `update.cmd` unter Windows, Overpass und OSM-API (kein Netz), die Seiten im Browser. Der Patch bringt kein `docs/`, `dist/` und `data/derived/` mit; sie entstehen beim ersten Lauf und werden mit eingecheckt.

### S3 — Paket

**Ziel:** Die Beschreibungen der Items sagen, was sie sind, und der Eintrittsmarker kennt ODER-Bedingungen.

**Uploads:** das Bundle von `wikibase-static` (PRIMER dort); dieses PRIMER.

Vorschlag zum Zuschnitt, vor dem Bauen als Formular zu bestätigen: (a) die Beschreibungswörter je Klasse (englisch und deutsch) kommen aus `entities.csv` oder den Seeds statt aus der festen Tabelle `THINGS`; der Rückfall der Benchmarks bleibt, damit `osm-benchmarks-static` unverändert baut. (b) Die Tag-Bedingung einer Auswahl kann mehrere Gruppen haben, von denen **eine** zutreffen muss (z. B. eine Spalte `group` in `data/seeds/<name>.csv`; Zeilen derselben Gruppe bleiben UND, Gruppen sind ODER); ohne die Spalte verhält sich alles wie heute. Der Auftrag gilt gleichzeitig für `osm-holywells-static`, `osm-ogham-static`, `osm-sisal-static` und `osm-govan-static`.

Aus dem Harvest 2026-11-18 kommen zwei Wünsche dazu: (c) `wikimedia_commons` mit einer Kategorie nicht verlieren (0 Elemente hier), (d) Löschversionen (Versionen ohne Position) benennen statt nur zu melden. Beides darf auch später kommen; die Rohdaten liegen committet, der Import läuft offline neu.

**Abnahme:** Tests im Paket; in einer Kopie dieses Repos mit einem Probe-Element trägt das Item die richtige Beschreibung, der Eintrittsmarker steht bei einem Element, das nur eine der neun Bedingungen erfüllt; `check-crm` meldet keinen Verstoß; `osm-benchmarks-static` baut mit der neuen Version byteweise gleich.

### S4 bis S7

Wie die Schritte S5 bis S8 von `osm-benchmarks-static` (dort ausführlich und mit Befunden): Harvest mit Netz (`python main.py import-osm --probe --contact <Adresse>` zuerst, dann ohne `--probe`, bei Flo), Import, Seiten, `check-crm`, danach die Abfragen und die Veröffentlichung. Besonderheiten hier:
- **S4** Abnahme: 8 Elemente (oder die Zahl der heutigen Overpass-Antwort), Zahl der Version-Statements je Element = Zahl der Versionen der API-History (Versionen ohne Position, also Löschungen, ausgenommen; der Importer meldet sie), jede Historie vollständig, zweiter Lauf stellt nur die Overpass-Anfrage; `queries.yaml` gelöscht. Da der Harvest bei Flo läuft und er selbst committet, braucht S4 keinen Patch.
- **S5** an Way und Relation: Geometrie-Verlauf als WKT, Karte, GeoSPARQL; Abnahme: das Gebäude und die Friedhofsfläche erscheinen auf der Karte, die Zahl der Requests (Stützpunkte) ist notiert.
- **S6** auch eine Abfrage für Elemente mit `wikidata`-Tag, um die Brücke zu `wd-govanstones-static` zu zeigen.
- **S7** `deploy: false` entfernen und `&& python check_attribution.py` im Aufrufer ergänzen; einmal im Repo: Settings → Pages → Source „GitHub Actions“ und Actions → General → „Allow GitHub Actions to create and approve pull requests“ (für `update.yml`).

### Erledigt 2026-11-18 (S4 Rohdaten, S5 Geometrie, S6 Abfragen)

- **S4:** Rohdaten geerntet und committet (Commit 1863b34), Befund 8. Der Import wartet auf S3.
- **S5:** Die Geometrie von Ways und Relationen ist mit den Rohdaten getestet (Befund 8).
- **S6:** `queries.yaml` ersetzt die vorläufige Datei: die Abfragen der Benchmarks mit dem Präfix `ogs` und diese Abfragen für die Site: Versionen je Element, Eintrittsversion, Änderungen seit einem Datum, Benutzer mit den meisten Versionen, Positionswechsel, Position zu einem Zeitpunkt, Elemente mit Wikidata-Item, Elemente mit einem bestimmten Tag, Form-Änderungen von Ways und Relationen, dazu die allgemeinen Abfragen des Pakets. Jede Abfrage liefert mindestens eine Zeile (sonst bricht `--strict` ab); getestet mit `wikibase-static` v0.28.0.

---

## Teil D — Offene Punkte

- **Tag-Bedingung (Befund 3):** Platzhalter `name`. Entscheiden mit S3: ODER-Gruppen im Paket (Vorschlag) oder die Abfrage so umbauen, dass eine gemeinsame Bedingung existiert (geht nicht ohne Verlust: Kirche und Friedhof teilen keinen Tag).
- **Klassen:** eine Klasse (`crm:E18`) statt Kirche, Friedhof, Museum, Stein, weil das Paket nur eine Klasse je Site kann. Mehrere Klassen wären eine spätere Paketerweiterung (gleicher Wunsch kann bei den wd-Sites auftreten).
- **Logo:** erledigt (Sarkophag, CC BY 4.0).
- **Präfix:** `ogs` ist ein Vorschlag; die Schwestern haben `ohs`, `oos`, `oss`. Änderung vor der ersten Veröffentlichung möglich.
- **Gebiet:** 120 m um 55.864725, −4.313125 sind eng gewählt; wenn das Gelände (Govan Old Churchyard, Hogbacks, Nachbargebäude) größer gefasst werden soll, sagt Flo Bescheid; dann Abfrage und Befund 2 anpassen.
- **Wikidata-Brücke:** Wie die OSM-Elemente mit den Wikidata-Items von `wd-govanstones-static` verbunden werden (nur über das Tag `wikidata`, als Property-Wert ohne `owl:sameAs`), mit S6 klären.
- **Netz:** `import-osm` ist hier noch nicht gelaufen; beim ersten Lauf `--contact` setzen und die Pause prüfen.

**Dazugekommen 2026-11-18 (Harvest):**

- **Löschversionen:** Versionen ohne Position (Löschungen) übergeht der Importer; die Zahl der Version-Statements ist dann kleiner als die der API-Versionen. Die Abnahmeregel von S4 nimmt sie aus; offen, ob sie ein eigenes Statement bekommen sollen (S3 oder danach).
- **Eintrittsmarker:** die Relation (Friedhof) hat keinen, weil der Platzhalter `name` verlangt (Befund 3).
- **Wikidata-Brücke:** 7 von 8 Elementen haben ein `wikidata`-Tag; die Abfrage `osm-wikidata` zeigt sie. Ob eine Property „entspricht Wikidata-Item“ im Modell dazukommt, ist offen.
- **Veröffentlichung (S7):** erst nach S3 und dem Rollout, weil die Beschreibungen sonst „Benchmark …“ lauten: in `.github/workflows/site.yml` `deploy: false` durch `deploy: true` ersetzen und `&& python check_attribution.py` an den Befehl hängen (siehe PATCH-README).
