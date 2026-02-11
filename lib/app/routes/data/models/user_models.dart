/// Modèle de données pour un utilisateur
/// Représente la structure des données utilisateur
class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final String? address;
  
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.address,
  });

  /// Créer un UserModel depuis un JSON (Map)
  /// Utilisé lors de la réception de données de l'API
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      address: json['address'] as String?,
    );
  }

  /// Convertir un UserModel en JSON (Map)
  /// Utilisé lors de l'envoi de données vers l'API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'address': address,
    };
  }

  /// Créer une copie du UserModel avec certains champs modifiés
  /// Utile pour la mise à jour partielle des données
  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    String? address,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      address: address ?? this.address,
    );
  }

  /// Convertir le UserModel en String (utile pour le débogage)
  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email)';
  }

  /// Comparer deux UserModel
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is UserModel &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.avatar == avatar &&
        other.address == address;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        phone.hashCode ^
        avatar.hashCode ^
        address.hashCode;
  }
}

/*
EXPLICATION DÉTAILLÉE:

1. **Qu'est-ce qu'un Modèle?**
   - Représente la structure des données de votre application
   - Correspond généralement à une table de base de données ou un endpoint API
   - Sépare les données de la logique métier et de l'UI
   - Facilite la manipulation et la validation des données

2. **Champs de la Classe**
   - final: Les valeurs ne peuvent pas être modifiées après la création
   - required: Champs obligatoires lors de la création
   - ?: Champs optionnels (peuvent être null)
   
   Exemple:
   - id, name, email sont obligatoires (required)
   - phone, avatar, address sont optionnels (?)

3. **Constructeur**
   - Définit comment créer une instance de UserModel
   - required pour les champs obligatoires
   - this.field pour les champs optionnels
   
   Utilisation:
   ```dart
   var user = UserModel(
     id: 1,
     name: 'Ahmed',
     email: 'ahmed@example.com',
   );
   ```

4. **factory UserModel.fromJson()**
   - "factory" = constructeur spécial qui peut retourner une instance existante
   - Convertit JSON (Map) en objet UserModel
   - Utilisé quand on reçoit des données de l'API
   
   Exemple:
   ```dart
   Map<String, dynamic> json = {
     'id': 1,
     'name': 'Ahmed',
     'email': 'ahmed@example.com',
   };
   
   UserModel user = UserModel.fromJson(json);
   ```
   
   Pourquoi "as int" et "as String?"?
   - Type casting pour la sécurité des types
   - as int: obligatoire, lance une erreur si null
   - as String?: optionnel, retourne null si absent

5. **toJson()**
   - Convertit l'objet UserModel en JSON (Map)
   - Utilisé quand on envoie des données vers l'API
   
   Exemple:
   ```dart
   UserModel user = UserModel(id: 1, name: 'Ahmed', email: 'ahmed@example.com');
   Map<String, dynamic> json = user.toJson();
   // json = {'id': 1, 'name': 'Ahmed', 'email': 'ahmed@example.com', ...}
   ```

6. **copyWith()**
   - Crée une copie du modèle avec certains champs modifiés
   - Très utile car les champs sont final (immutables)
   - Suit le principe d'immutabilité (bonnes pratiques)
   
   Exemple:
   ```dart
   UserModel user1 = UserModel(id: 1, name: 'Ahmed', email: 'ahmed@example.com');
   
   // Créer une copie avec un nom différent
   UserModel user2 = user1.copyWith(name: 'Mohammed');
   // user1.name = 'Ahmed' (inchangé)
   // user2.name = 'Mohammed' (nouveau)
   ```
   
   Le ?? opérateur:
   - name ?? this.name signifie: utilise "name" s'il est fourni, sinon garde this.name

7. **toString()**
   - Surcharge de la méthode par défaut
   - Retourne une représentation lisible de l'objet
   - Très utile pour le débogage avec print()
   
   Exemple:
   ```dart
   print(user); // Affiche: UserModel(id: 1, name: Ahmed, email: ahmed@example.com)
   ```

8. **operator ==**
   - Définit comment comparer deux UserModel
   - identical(): vérifie si c'est le même objet en mémoire
   - Sinon, compare tous les champs
   
   Exemple:
   ```dart
   UserModel user1 = UserModel(id: 1, name: 'Ahmed', email: 'ahmed@example.com');
   UserModel user2 = UserModel(id: 1, name: 'Ahmed', email: 'ahmed@example.com');
   
   print(user1 == user2); // true (même contenu)
   ```

9. **hashCode**
   - Obligatoire quand on surcharge operator ==
   - Utilisé pour les collections (Set, Map)
   - ^ = opérateur XOR pour combiner les hash codes

10. **Flux de Données Typique**
    
    API → Repository → Controller → View:
    ```dart
    // 1. L'API retourne du JSON
    {'id': 1, 'name': 'Ahmed', 'email': 'ahmed@example.com'}
    
    // 2. Le Repository convertit en UserModel
    UserModel user = UserModel.fromJson(json);
    
    // 3. Le Controller stocke et manipule
    var currentUser = user.obs; // Observable GetX
    
    // 4. La View affiche
    Text(controller.currentUser.value.name)
    ```

11. **Avantages de cette Approche**
    - Type-safety: Le compilateur détecte les erreurs
    - Auto-complétion dans l'IDE
    - Facilite la maintenance (changer la structure en un endroit)
    - Sérialisation/désérialisation automatique
    - Code plus propre et lisible
    - Facilite les tests unitaires

12. **Extension Possible: Validation**
    ```dart
    // Méthode pour valider l'email
    bool isValidEmail() {
      return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
    }
    
    // Méthode pour obtenir les initiales
    String getInitials() {
      List<String> names = name.split(' ');
      return names.length >= 2 
        ? '${names[0][0]}${names[1][0]}'.toUpperCase()
        : name[0].toUpperCase();
    }
    ```

13. **Alternative Moderne: Freezed Package**
    Le package "freezed" peut générer automatiquement tout ce code:
    - fromJson / toJson
    - copyWith
    - == et hashCode
    - toString
    
    Mais pour comprendre les concepts, il est important de le faire manuellement d'abord.
*/
