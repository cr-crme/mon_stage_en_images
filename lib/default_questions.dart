import 'package:mon_stage_en_images/common/models/enum.dart';
import 'package:mon_stage_en_images/common/models/question.dart';

class DefaultQuestion {
  // These are the default questions when creating a new teacher
  // [section] are : M=0, E=1, T=2, I=3, E=4, R=5 and [defaultTarget] should
  // either be Target.all or Target.none depending if it should be automatically
  // active for all or no one, respectively
  static List<Question> get questions => [
        Question(
          'Prends une photo des collègues de ton département.'
          '\nSi tu as un problème ou que tu ne sais pas quoi faire, à qui est ce que '
          'tu peux demander de l’aide?',
          section: 5,
          defaultTarget: Target.none,
          canBeDeleted: false,
        ),
        Question(
          'Prends en photo la personne avec qui tu travailles le plus.'
          '\nQui dois-tu aller voir si elle est absente?',
          section: 5,
          defaultTarget: Target.none,
          canBeDeleted: false,
        ),
        Question(
          'Fais-toi prendre en photo avec un ou une collègue pendant que vous '
          'faites une tâche en équipe. '
          '\nExplique à quoi sert cette tâche.',
          section: 5,
          defaultTarget: Target.none,
          canBeDeleted: false,
        ),
        Question(
          'Prends en photo la personne qui te donne les tâches à faire.'
          '\nExplique son rôle dans l’entreprise.',
          section: 5,
          defaultTarget: Target.all,
          canBeDeleted: false,
        ),
        Question(
          'Prends une photo de ton poste de travail.'
          '\nEst-ce qu’il y fait sombre ou lumineux?',
          section: 4,
          defaultTarget: Target.none,
          canBeDeleted: false,
        ),
        Question(
          'Prends une photo de ton département.'
          '\nEst-ce qu’il y fait chaud ou froid?',
          section: 4,
          defaultTarget: Target.none,
          canBeDeleted: false,
        ),
        Question(
          'Prends une photo de l’extérieur de ton entreprise.',
          section: 4,
          defaultTarget: Target.none,
          canBeDeleted: false,
        ),
        Question(
          'Prends une photo de ton poste de travail.'
          '\nEst-ce qu’il y a du bruit?',
          section: 4,
          defaultTarget: Target.all,
          canBeDeleted: false,
        ),
        Question(
          'Demande à tes collègues de te prendre en photo pendant que tu '
          'fais la tâche que tu préfères en stage. '
          '\nExplique pourquoi tu aimes faire cette tâche?',
          section: 3,
          defaultTarget: Target.none,
          canBeDeleted: false,
        ),
        Question(
          'Demande à tes collègues de te prendre en photo pendant que tu travailles.'
          '\nDécris tes caractéristiques.',
          section: 3,
          defaultTarget: Target.all,
          canBeDeleted: false,
        ),
        Question(
          'Demande à tes collègues de te prendre en photo pendant que tu '
          'remets un pneu sur une voiture.'
          '\nDécris ce que tu fais.',
          section: 2,
          defaultTarget: Target.none,
          canBeDeleted: false,
        ),
        Question(
          'Demande à tes collègues de te prendre en photo pendant que tu '
          'donnes le bain à un chien.'
          '\nQuelles sont les choses auxquelles tu dois faire attention quand '
          'tu réalises cette tâche?',
          section: 2,
          defaultTarget: Target.none,
          canBeDeleted: false,
        ),
        Question(
          'Demande à tes collègues de te prendre en photo pendant que tu '
          'places des marchandises dans le magasin.'
          '\nComment as-tu appris à faire cette tâche?',
          section: 2,
          defaultTarget: Target.none,
          canBeDeleted: false,
        ),
        Question(
          'Quelle est la tâche que tu fais le plus souvent?'
          '\nDemande à tes collègues de te prendre en photo pendant que '
          'tu fais cette tâche.'
          '\nQu’est-ce que tu trouves le plus difficile dans cette tâche?',
          section: 2,
          defaultTarget: Target.all,
          canBeDeleted: false,
        ),
        Question(
          'Est-ce que tes collègues se servent des mêmes équipements que toi?'
          '\nPrends en photo leurs équipements.',
          section: 1,
          defaultTarget: Target.none,
          canBeDeleted: false,
        ),
        Question(
          'Prends en photo l’équipement que tu aimes le plus utiliser.'
          '\nComment as-tu appris à utiliser cet équipement?',
          section: 1,
          defaultTarget: Target.none,
          canBeDeleted: false,
        ),
        Question(
          'Prends en photo l’équipement que tu utilises le plus souvent.'
          '\nQuel est l’entretien à faire pour que cet équipement soit en bon '
          'état?',
          section: 1,
          defaultTarget: Target.none,
          canBeDeleted: false,
        ),
        Question(
          'Prends en photo l’outil le plus dangereux que tu utilises.'
          '\nPourquoi est-il dangereux?',
          section: 1,
          defaultTarget: Target.none,
          canBeDeleted: false,
        ),
        Question(
          'Prends en photo les équipements que tu utilises pour faire ton travail.'
          '\nÀ quoi servent-ils?',
          section: 1,
          defaultTarget: Target.all,
          canBeDeleted: false,
        ),
        Question(
          'Prends en photo les essences de bois avec lesquelles tu travailles.'
          '\nQu’est-ce qui change quand tu coupes une planche en érable '
          'par rapport à une planche en épinette?',
          section: 0,
          defaultTarget: Target.none,
          canBeDeleted: false,
        ),
        Question(
          'Prends en photo l’aliment que tu trouves le plus difficile à découper.',
          section: 0,
          defaultTarget: Target.none,
          canBeDeleted: false,
        ),
        Question(
          'Prends en photo la marchandise que tu trouves la plus difficile '
          'à transporter.',
          section: 0,
          defaultTarget: Target.none,
          canBeDeleted: false,
        ),
        Question(
          'Prends en photo un produit avec un symbole SIMDUT que tu as déjà '
          'utilisé.'
          '\nQuelle est la signification du symbole?',
          section: 0,
          defaultTarget: Target.all,
          canBeDeleted: false,
        ),
        Question(
          'Prends en photo les produits avec lesquels tu travailles.',
          section: 0,
          defaultTarget: Target.all,
          canBeDeleted: false,
        ),
      ];
}
