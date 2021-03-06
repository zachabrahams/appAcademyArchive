Pokedex.RootView.prototype.addToyToList = function (toy) {
  $li = $("<li>" + " " +  toy.escape("name") +
          " " +  toy.escape("happiness") + " " +
          toy.escape("price") + "</li>");
  $li.data("toy-id", toy.get("id")).data("pokemon-id", toy.get("pokemon_id"))
  this.$pokeDetail.find("ul.toys").append($li);
};

Pokedex.RootView.prototype.renderToyDetail = function (toy) {
  var $detail = $("<div class='detail'></div>");

  var attrs = ["name", "price", "happiness"];
  $detail.append("<img src='" + toy.escape("image_url") + "'>");
  attrs.forEach( function (attr) {
    $detail.append("<div class='" + attr + "'>" + attr + ": " + toy.escape(attr) + "</div>");
  });

  var $sel = $("<select>").data("pokemon-id", toy.get("pokemon_id")).data("toy-id", toy.get("id"));

  this.pokes.forEach( function (poke) {
    var $option = $("<option>").val(poke.get("id")).text(poke.escape("name"));
    if (toy.get("pokemon_id") === poke.get("id")) {
      $option.prop("selected", true);
    }
    $sel.append($option);
  });
  $detail.append($sel);
  this.$toyDetail.html($detail);
};

Pokedex.RootView.prototype.selectToyFromList = function (event) {
  var $toy = $(event.currentTarget);
  var toyId = $toy.data("toy-id");
  var pokemonId = $toy.data("pokemon-id");
  var pokemon = this.pokes.get(pokemonId);
  var toy = pokemon.toys().get(toyId);
  this.renderToyDetail(toy);
};
