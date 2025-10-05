class FormValidators { // Classe de validadores de formulário

  // Validador de nulidade
  static String? notNull(String? value){
    if (value == null || value.isEmpty) return "Campo obrigatório";
    return null;
  }

  // Validador de nome de usuário
  static String? validateUsername(String? value){
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }
    if (value.length < 3) {
      return 'Seu nome de usuário deve ter mais de 3 caracteres';
    }
    //Verificar se já existe o Username no banco de dados.
    return null;
  }

  // Validador de e-mail
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }
    // Regex para validar o formato de e-mail padrão.
    const pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final regExp = RegExp(pattern);
    if (!regExp.hasMatch(value)) {
      return 'Por favor, insira um e-mail válido';
    }
    return null;
  }

  // Validador de telefone
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }
    // Remove a máscara e caracteres não numéricos.
    final String phone = value.replaceAll(RegExp(r'[^\d]'), '');
    
    // Verifica se o telefone tem 10 (fixo com DDD) ou 11 (celular com DDD) dígitos.
    if (phone.length < 9 || phone.length > 11) {
      return 'Número de telefone inválido';
    }
    return null;
  }
}