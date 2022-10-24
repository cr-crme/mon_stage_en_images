import './common/models/enum.dart';
import './common/models/question.dart';

class DefaultQuestion {
  // These are the default questions when creating a new teacher
  // [section] are : M=0, E=1, T=2, I=3, E=4, R=5 and [defaultTarget] should
  // either be Target.all or Target.none depending if it should be automatically
  // active for all or no one, respectively
  static final questions = [
    Question(
      'Prends en photo et décris les produits avec lesquels tu travailles.',
      section: 0,
      defaultTarget: Target.none,
    ),
    Question(
      'Quelle est la marchandise la plus difficile à porter?',
      section: 0,
      defaultTarget: Target.none,
    ),
    Question(
      'Quels sont les produits que tu déplaces le plus fréquemment avec '
      'le chariot?',
      section: 0,
      defaultTarget: Target.none,
    ),
    Question(
      'Quelle est la marchandise la plus difficile à déplacer avec le '
      'transpalette?',
      section: 0,
      defaultTarget: Target.none,
    ),
    Question(
      'Quel aliment est le plus difficile à découper?',
      section: 0,
      defaultTarget: Target.none,
    ),
    Question(
      'Avec quelles essences de bois tu travailles? '
      '\nQu’est-ce qui change quand tu coupes une planche en érable et '
      'une planche en épinette?',
      section: 0,
      defaultTarget: Target.none,
    ),
    Question(
      'Prends une photo d’un produit avec un symbole SIMDUT. '
      '\nQuelle est la signification du symbole?',
      section: 0,
      defaultTarget: Target.none,
    ),
    Question(
      'Quel produit avec un symbole SIMDUT as-tu déjà utilisé? '
      '\nDans quelles circonstances ?',
      section: 0,
      defaultTarget: Target.none,
    ),
    Question(
      'Quels sont les équipements que tu utilises pour faire ton travail? '
      '\nÀ quoi servent-ils?',
      section: 1,
      defaultTarget: Target.none,
    ),
    Question(
      'Est-ce que tes collègues utilisent les mêmes équipements que toi? '
      '\nPrends en photo leurs équipements.',
      section: 1,
      defaultTarget: Target.none,
    ),
    Question(
      'Quel est l’outil le plus dangereux que tu utilises? '
      '\nExplique pourquoi est-il dangereux?',
      section: 1,
      defaultTarget: Target.none,
    ),
    Question(
      'Quel est l’équipement que tu utilises le plus souvent? '
      '\nEst-ce qu’il est en bon état?',
      section: 1,
      defaultTarget: Target.none,
    ),
    Question(
      'Comment as-tu appris à utiliser cet équipement? '
      '\nPrends en photo la personne qui t’a montré comment s’en servir.',
      section: 1,
      defaultTarget: Target.none,
    ),
    Question(
      'Quel est l’entretien à faire pour que cet équipement soit en bon état?',
      section: 1,
      defaultTarget: Target.none,
    ),
    Question(
      'Quel équipement aimes-tu le moins utiliser? Pourquoi?',
      section: 1,
      defaultTarget: Target.none,
    ),
    Question(
      'Quel équipement aimes-tu le plus utiliser? Pourquoi?',
      section: 1,
      defaultTarget: Target.none,
    ),
    Question(
      'Quelle est la tâche que tu fais le plus souvent? '
      '\nFais toi prendre en photo pendant que tu fais cette tâche.',
      section: 2,
      defaultTarget: Target.none,
    ),
    Question(
      'Est-ce que tu fais cette tâche tout seul ou avec un collègue? '
      '\nPrends en photo la personne qui fait la tâche avec toi.',
      section: 2,
      defaultTarget: Target.none,
    ),
    Question(
      'Comment as-tu appris à faire cette tâche? '
      '\nPrends en photo la personne qui a fait ta formation.',
      section: 2,
      defaultTarget: Target.none,
    ),
    Question(
      'Quelles sont les choses auxquelles tu dois faire attention quand '
      'tu fais cette tâche?',
      section: 2,
      defaultTarget: Target.none,
    ),
    Question(
      'Quelle est la tâche que tu trouves la plus facile? '
      '\nFais toi prendre en photo pendant que tu fais cette tâche.',
      section: 2,
      defaultTarget: Target.none,
    ),
    Question(
      'Quelle est la tâche que tu trouves la plus difficile? '
      '\nFais toi prendre en photo pendant que tu fais cette tâche.',
      section: 2,
      defaultTarget: Target.none,
    ),
    Question(
      'Demande à un collègue de te prendre en photo pendant que tu travailles. '
      '\nDécris tes caractéristiques.',
      section: 3,
      defaultTarget: Target.none,
    ),
    Question(
      'Prends une photo de ce que tu aimes le plus dans ton stage?',
      section: 3,
      defaultTarget: Target.none,
    ),
    Question(
      'Prends une photo de ce que tu aimes le moins dans ton stage?',
      section: 3,
      defaultTarget: Target.none,
    ),
    Question(
      'Prends une photo de ton poste de travail. '
      '\nEst-ce qu’il y a du bruit?',
      section: 4,
      defaultTarget: Target.none,
    ),
    Question(
      'Prends une photo de ton poste de travail. '
      '\nEst-ce qu’il y fait chaud ou froid?',
      section: 4,
      defaultTarget: Target.none,
    ),
    Question(
      'Prends une photo de ton poste de travail. '
      '\nEst-ce qu’il y fait sombre ou lumineux?',
      section: 4,
      defaultTarget: Target.none,
    ),
    Question(
      'Qui est la personne qui te donne les tâches à faire? '
      '\nExplique son rôle dans l’entreprise.',
      section: 5,
      defaultTarget: Target.none,
    ),
    Question(
      'Qui est la personne avec laquelle tu travailles le plus? '
      '\nQui dois-tu aller voir si elle est absente?',
      section: 5,
      defaultTarget: Target.none,
    ),
    Question(
      'Si tu as un problème ou que tu ne sais pas quoi faire, à qui est ce que '
      'tu peux demander de l’aide?',
      section: 5,
      defaultTarget: Target.none,
    ),
  ];
}
