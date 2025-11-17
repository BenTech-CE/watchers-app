enum TypeFilterSearch {
  all,
  profiles,
  lists,
  series,
  reviews;

  static TypeFilterSearch getTypeFilterSearch(String value) {
    return switch (value) {
      "Tudo" => TypeFilterSearch.all,
      "Séries" => TypeFilterSearch.series,
      "Usuários" => TypeFilterSearch.profiles,
      "Listas" => TypeFilterSearch.lists,
      "Reviews" => TypeFilterSearch.reviews,
      _ => TypeFilterSearch.all,
    };
  }
}
