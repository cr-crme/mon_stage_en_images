import 'package:flutter/material.dart';
import 'package:mon_stage_en_images/common/widgets/content_card.dart';
import 'package:mon_stage_en_images/screens/login/go_to_irsst_screen.dart';
import 'package:mon_stage_en_images/screens/q_and_a/main_metier_page.dart';
import 'package:url_launcher/url_launcher.dart';

final Uri adoprevitStageImagesUri = Uri(
  scheme: 'https',
  host: 'adoprevit.org',
  path: 'stage-en-images',
);

final List<ContentCard> resourcesCard = [
  ContentCard(
    coverUri: 'assets/images/cover_learn_sst.jpeg',
    title: 'Apprendre sur la SST',
    description:
        '''Une fiche produite par l'IRSST (Institut de recherche Robert-Sauvé en santé '''
        '''et en Sécurité au Travail) pour la supervision de stagiaires en métiers semi-spécialisées''',
    primaryAction: (BuildContext context) async {
      await launchUrl(GoToIrsstScreen.learnAboutSstUri);
      if (!context.mounted) return;
      if (Navigator.canPop(context)) Navigator.of(context).pop();
    },
  ),
  ContentCard(
    coverUri: 'assets/images/cover_metier.png',
    title: 'Apprendre sur M.É.T.I.E.R.',
    description: '''Une publication de la chaire de recherche ADOPREVIT '''
        '''décrivant un modèle d'analyse de l'activité de travail centré sur la personne en situation.'''
        ''' Ce document explore les déterminants de l'activité qui composent l'acronyme M.É.T.I.E.R. ''',
    primaryAction: (BuildContext context) async {
      await launchUrl(GoToIrsstScreen.learnAboutMetierUri);
      if (!context.mounted) return;
      if (Navigator.canPop(context)) Navigator.of(context).pop();
    },
  ),
  ContentCard(
    coverUri: 'assets/images/cover_questions.jpg',
    title: 'Exemples de questions',
    description:
        '''Une liste de questions pour les enseignantes et enseignants à utiliser pour faire'''
        ''' verbaliser l'élève sur son activité de travail au Parcours de formation axée sur'''
        ''' l'emploi (lors des visites en stage ou lors des retours réflexifs en classe).''',
    primaryAction: (BuildContext context) async {
      await launchUrl(MainMetierPage.questionIdeasUri);
      if (!context.mounted) return;
      if (Navigator.canPop(context)) Navigator.of(context).pop();
    },
  )
];
