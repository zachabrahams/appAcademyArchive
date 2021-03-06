Pokedex.RootView.prototype.addPokemonToList = function (pokemon) {
  var $li = $("<li></li>").addClass("poke-list-item");
  $li.data("id", pokemon.get("id"));
  $li.append(pokemon.escape("name") + " " + pokemon.escape("poke_type"));
  this.$pokeList.append($li);
};

Pokedex.RootView.prototype.refreshPokemon = function (callback) {
  var that = this;
  this.pokes.fetch({
    success: function(pokemons) {
      that.pokes.forEach(function(pokemon){
        that.addPokemonToList(pokemon);
      })
    }
  });
};
