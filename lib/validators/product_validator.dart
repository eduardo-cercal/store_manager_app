class ProductValidator {
  String? validateTitle(String? text) {
    if (text == null || text.isEmpty) {
      return "Preencha o título do produto";
    } else {
      return null;
    }
  }

  String? validateDescription(String? text) {
    if (text == null || text.isEmpty) {
      return "Preencha a descrição do produto";
    } else {
      return null;
    }
  }

  String? validatePrice(String? text) {
    double? price = double.tryParse(text!);
    if (price != null) {
      if (!text.contains(".") || text.split(".")[1].length != 2) {
        return "Utiliza 2 casas decimais";
      }
    } else {
      return "Preço Inválido!";
    }
    return null;
  }

  String? validateImages(List? images) {
    if (images == null || images.isEmpty) {
      return "Adicione imagens do produto";
    } else {
      return null;
    }
  }
}
