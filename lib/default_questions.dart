import 'package:mon_stage_en_images/common/models/enum.dart';
import 'package:mon_stage_en_images/common/models/question.dart';

class DefaultQuestion {
  // These are the default questions when creating a new teacher
  // [section] are : M=0, E=1, T=2, I=3, E=4, R=5 and [defaultTarget] should
  // either be Target.all or Target.none depending if it should be automatically
  // active for all or no one, respectively
  static List<Question> get questions => [
        Question(
          'Fais-tu cette tâche en équipe ?'
          '\nPrends une photo en faisant une tâche avec un collègue.',
          section: 5,
          defaultTarget: Target.none,
          canBeDeleted: false,
        ),
        Question(
          'Quelles sont les personnes avec qui tu travailles le plus souvent ? '
          'Explique son rôle dans l\'entreprise.',
          section: 5,
          defaultTarget: Target.none,
          canBeDeleted: false,
        ),
        Question(
          'Quelles sont les personnes qui te donnent des tâches à faire ?'
          '\nExplique leur rôle dans l’entreprise.',
          section: 5,
          defaultTarget: Target.all,
          canBeDeleted: false,
        ),
        Question(
          'Est-ce que tu peux déplacer le mobilier (chaises, meubles, tables, comptoirs, etc.)'
          '\npour que ce soit plus facile d\'y travailler ?',
          section: 4,
          defaultTarget: Target.none,
          canBeDeleted: false,
        ),
        Question(
          'Prends une photo de l\'aménagement '
          'à ton poste de travail (bureau, comptoir, allées du magasin).',
          section: 4,
          defaultTarget: Target.none,
          canBeDeleted: false,
        ),
        Question(
          'Prends une photo de l\'endroit où tu travailles lorsque tu fais cette tâche.'
          '\nDécris-le moi (lumière, température, encombré).',
          section: 4,
          defaultTarget: Target.all,
          canBeDeleted: false,
        ),
        Question(
          'Qu\'est ce que tu as appris depuis que tu fais cette tâche ?',
          section: 3,
          defaultTarget: Target.none,
          canBeDeleted: false,
        ),
        Question(
          'Qu\'est ce que tu trouves le plus difficile dans cette tâche ? Explique-moi.',
          section: 3,
          defaultTarget: Target.none,
          canBeDeleted: false,
        ),
        Question(
          'Prends en photo une tâche que tu aimes le moins faire'
          ' ou qui te rend nerveux ou nerveuse ?',
          section: 3,
          defaultTarget: Target.none,
          canBeDeleted: false,
        ),
        Question(
          'Prends en photo une tâche que tu aimes le plus faire'
          ' ou qui te rend fier ou fière ?',
          section: 3,
          defaultTarget: Target.none,
          canBeDeleted: false,
        ),
        Question(
          'Prends une photo de toi en réalisant cette tâche.'
          ' Est-ce que tu réussis bien cette tâche ? Explique-moi.',
          section: 3,
          defaultTarget: Target.all,
          canBeDeleted: false,
        ),
        Question(
          'Est-ce que tu dois demander de l\'aide '
          'pour réaliser cette tâche en sécurité ?',
          section: 2,
          defaultTarget: Target.none,
          canBeDeleted: false,
        ),
        Question(
          'As-tu trouvé des trucs par toi-même pour faire la tâche plus vite '
          'ou qu\'elle soit plus facile ?',
          section: 2,
          defaultTarget: Target.none,
          canBeDeleted: false,
        ),
        Question(
          'Quelles sont les choses auxquelles tu dois faire attention '
          'quand tu réalises cette tâche ? ',
          section: 2,
          defaultTarget: Target.none,
          canBeDeleted: false,
        ),
        Question(
          'Décris les étapes pour réaliser la tâche visée.'
          '\nDemande à tes collègues de te prendre en photo pendant que '
          'tu fais cette tâche.',
          section: 2,
          defaultTarget: Target.all,
          canBeDeleted: false,
        ),
        Question(
          'Prends en photo un équipement que tu dois ajuster ou préparer avant de l’utiliser.'
          '\nQuelles sont les étapes à suivre ?',
          section: 1,
          defaultTarget: Target.none,
          canBeDeleted: false,
        ),
        Question(
          'Prends en photo l’équipement que tu aimes le plus utiliser.'
          '\nComment as-tu appris à l\'utiliser ?',
          section: 1,
          defaultTarget: Target.none,
          canBeDeleted: false,
        ),
        Question(
          'Prends en photo un équipement qui a besoin d\'entretien pour qu\'il reste en bon état.'
          '\nComment est-ce que tu l\'entretiens ?',
          section: 1,
          defaultTarget: Target.none,
          canBeDeleted: false,
        ),
        Question(
          'Prends en photo l’outil le plus dangereux que tu utilises.'
          '\nPourquoi est-il dangereux ?',
          section: 1,
          defaultTarget: Target.none,
          canBeDeleted: false,
        ),
        Question(
          'Prends en photo les équipements que tu utilises pour faire ton travail.'
          '\nÀ quoi servent-ils ?',
          section: 1,
          defaultTarget: Target.all,
          canBeDeleted: false,
        ),
        Question(
          'Prends en photo un produit ou matériel que tu dois manipuler avec précision',
          section: 0,
          defaultTarget: Target.none,
          canBeDeleted: false,
        ),
        Question(
          'Prends en photo deux matériaux différents que tu utilises.'
          'Qu\'est-ce qui change dans la manière de les utiliser ?',
          section: 0,
          defaultTarget: Target.none,
          canBeDeleted: false,
        ),
        Question(
          'Prends en photo un matériel qui est difficile à transporter.',
          section: 0,
          defaultTarget: Target.none,
          canBeDeleted: false,
        ),
        Question(
          'Prends en photo un produit avec un symbole SIMDUT.'
          '\nQuelle est la signification du symbole ?',
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
