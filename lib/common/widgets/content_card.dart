import 'package:flutter/material.dart';

class ContentCard extends StatelessWidget {
  const ContentCard({
    super.key,
    this.coverUri,
    this.title,
    this.description,
    this.primaryAction,
    this.secondaryAction,
    this.primaryLabel = 'Consulter',
    this.secondaryLabel = 'Détails',
  });

  final String? coverUri;
  final String? title;
  final String? description;
  final void Function(BuildContext)? primaryAction;
  final String? primaryLabel;
  final void Function(BuildContext)? secondaryAction;
  final String? secondaryLabel;

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      elevation: 1,
      child: Column(
        children: [
          Flexible(
            fit: FlexFit.tight,
            flex: 1,
            child: coverUri != null
                ? Image.asset(
                    width: double.infinity,
                    coverUri!,
                    fit: BoxFit.fitWidth,
                  )
                : Container(
                    color: Theme.of(context).primaryColor,
                  ),
          ),
          Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  if (description != null) ...[
                    SizedBox(
                      height: 8,
                    ),
                    Expanded(
                      child: Text(
                        description!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (secondaryAction != null) ...[
                        OutlinedButton(
                            onPressed: () => secondaryAction!(context),
                            child: Text(
                              secondaryLabel!,
                            )),
                        SizedBox(
                          width: 12,
                        ),
                      ],
                      if (primaryAction != null)
                        FilledButton.tonal(
                            onPressed: () => primaryAction!(context),
                            child: Text(
                              primaryLabel!,
                              style: Theme.of(context).textTheme.titleMedium,
                            )),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
