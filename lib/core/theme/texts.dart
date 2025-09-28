
import 'package:flutter/material.dart';
import 'package:watchers/core/theme/colors.dart';

// TODO:
// 1. Verificar tamanhos das fontes
// 2. Verificar o DropShadow da fonte brilhante
// 3. Verificar se a fontFamily está sendo aplicada corretamente
// 4. Verificar as cores dos textos (associar com colors.dart)


const TextStyle tsTitleLargeBright = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 22,
  fontWeight: FontWeight.bold,
  color: tColorPrimary,
  shadows: [Shadow(
    blurRadius: 2,
    color: Colors.white,
  ),],
);

const TextStyle tsTitleLarge = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 22,
  fontWeight: FontWeight.bold,
  color: tColorPrimary
);

const TextStyle tsTitleMedium = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 18,
  fontWeight: FontWeight.w600,
);

const TextStyle tsTitleSmall = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 16,
  fontWeight: FontWeight.w500,
);

const TextStyle tsBodyLarge = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 14,
  fontWeight: FontWeight.normal,
);

const TextStyle tsBodyMedium = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 12,
  fontWeight: FontWeight.normal,
);

const TextStyle tsBodySmall = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 10,
  fontWeight: FontWeight.normal,
);

const TextStyle tsLabelLarge = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 14,
  fontWeight: FontWeight.w500,
);

const TextStyle tsLabelMedium = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 12,
  fontWeight: FontWeight.w500,
);

const TextStyle tsLabelSmall = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 10,
  fontWeight: FontWeight.w500,
);

