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
