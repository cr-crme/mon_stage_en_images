import 'package:flutter/material.dart';
import 'package:mon_stage_en_images/default_resources.dart';
import 'package:url_launcher/url_launcher.dart';

class AdoprevitResourcesCard extends StatelessWidget {
  const AdoprevitResourcesCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final gap = SizedBox(
      height: 12,
    );

    return Card.filled(
      elevation: 2,
      color: CardTheme.of(context).color,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Besoin d\'aide pour utiliser Stage en images ? ',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            gap,
            Image.asset(
              'assets/images/start.png',
              height: MediaQuery.sizeOf(context).height / 8,
            ),
            gap,
            Text(
                'Accédez aux principes, à la prise en main, aux activités pédagogiques associées '
                'et trouvez les réponses à vos questions techniques sur la page de présentation '
                'de l\'application'),
            gap,
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                      onPressed: () async {
                        await launchUrl(adoprevitStageImagesUri);
                        if (!context.mounted) return;
                        if (Navigator.canPop(context)) {
                          Navigator.of(context).pop();
                        }
                      },
                      icon: Icon(Icons.open_in_new),
                      label: Text('Consulter la prise en main')),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
