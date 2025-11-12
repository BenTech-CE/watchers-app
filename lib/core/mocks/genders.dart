import 'package:flutter/material.dart';
import 'package:watchers/core/models/series/genre_model.dart';

List<GenreModel> listGenres = [
  GenreModel(
    id: 10759,
    name: "Ação e Aventura",
    color: const Color(0xFFB71C1C), // vermelho escuro
    icon:
        '<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 32 32"><path fill="currentColor" d="M16 3C8.832 3 3 8.832 3 16s5.832 13 13 13s13-5.832 13-13S23.168 3 16 3m-1.125 2.063c.04-.005.084.003.125 0V6h2v-.938A10.96 10.96 0 0 1 26.938 15H26v2h.938A10.96 10.96 0 0 1 17 26.938V26h-2v.938A10.96 10.96 0 0 1 5.062 17H6v-2h-.938c.472-5.243 4.587-9.41 9.813-9.938zm7.22 4.843l-8.5 3.688l-3.69 8.5l8.5-3.688zM16 14.5c.8 0 1.5.7 1.5 1.5s-.7 1.5-1.5 1.5s-1.5-.7-1.5-1.5s.7-1.5 1.5-1.5"/></svg>',
  ),
  GenreModel(
    id: 16,
    name: "Animação",
    color: const Color(0xFF6A1B9A), // roxo escuro
    icon:
        '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"><path fill="currentColor" d="m9 4l2.5 5.5L17 12l-5.5 2.5L9 20l-2.5-5.5L1 12l5.5-2.5zm0 4.83L8 11l-2.17 1L8 13l1 2.17L10 13l2.17-1L10 11zM19 9l-1.26-2.74L15 5l2.74-1.25L19 1l1.25 2.75L23 5l-2.75 1.26zm0 14l-1.26-2.74L15 19l2.74-1.25L19 15l1.25 2.75L23 19l-2.75 1.26z"/></svg>',
  ),
  GenreModel(
    id: 35,
    name: "Comédia",
    color: const Color(0xFFF57F17), // amarelo escuro
    icon:
        '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"><path fill="currentColor" d="M12 2C6.486 2 2 6.486 2 12s4.486 10 10 10s10-4.486 10-10S17.514 2 12 2m0 18c-4.411 0-8-3.589-8-8s3.589-8 8-8s8 3.589 8 8s-3.589 8-8 8"/><path fill="currentColor" d="M12 18c4 0 5-4 5-4H7s1 4 5 4m5.555-9.168l-1.109-1.664l-3 2a1 1 0 0 0 .108 1.727l4 2l.895-1.789l-2.459-1.229zm-6.557 1.23a1 1 0 0 0-.443-.894l-3-2l-1.11 1.664l1.566 1.044l-2.459 1.229l.895 1.789l4-2a1 1 0 0 0 .551-.832"/></svg>',
  ),
  GenreModel(
    id: 80,
    name: "Crime",
    color: const Color(0xFF263238), // cinza azulado escuro
    icon:
        '<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512"><path fill="currentColor" d="M20 18v209.947l9.924 30.64c34.506-22.263 65.675-34.64 101.433-30.433L94.293 18zm397.707 0l-37.064 210.154c35.758-4.206 66.927 8.17 101.433 30.434l9.924-30.64V18zM193.145 245.31c5.361 5.193 6.517 15.154 7.12 21.655l21.26 11.031c1.888 5.184-3.41 15.26-8.29 15.977l-12.995-6.743c-.973 6.645-1.787 12.547-4.783 17.797l9.486 4.924c6.546 3.397 14.294 2.037 19.485-1.197c3.128-1.949 5.71-4.43 7.863-7.223c7.377 1.392 15.502 1.969 23.709 1.969s16.332-.577 23.709-1.969c2.154 2.793 4.735 5.274 7.863 7.223c5.191 3.234 12.939 4.594 19.485 1.197l9.486-4.924c-2.996-5.25-3.81-11.152-4.783-17.797l-12.994 6.743c-4.88-.717-10.179-10.793-8.291-15.977l21.26-11.031c.603-6.5 1.759-16.462 7.12-21.654c-2.663.092-5.482.912-8.27 1.97l-28.401 14.739c-6.546 3.397-9.895 10.514-10.239 16.62c-.11 1.967.01 3.89.287 5.774c-5.01.685-10.643 1.086-16.232 1.086s-11.222-.4-16.232-1.086c.276-1.883.397-3.807.287-5.773c-.344-6.107-3.693-13.225-10.239-16.621l-28.402-14.739c-2.787-1.058-5.606-1.878-8.27-1.97z"/></svg>',
  ),
  GenreModel(
    id: 99,
    name: "Documentário",
    color: const Color(0xFF37474F), // cinza escuro
    icon:
        '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"><path fill="currentColor" d="M12 2a10 10 0 1 0 10 10A10.011 10.011 0 0 0 12 2m0 18a8 8 0 1 1 8-8a8.009 8.009 0 0 1-8 8m0-14a1 1 0 0 0-1 1v5l4.28 2.54a1 1 0 0 0 .96-1.74L13 11.47V7a1 1 0 0 0-1-1"/></svg>',
  ),
  GenreModel(
    id: 18,
    name: "Drama",
    color: const Color(0xFF4E342E), // marrom escuro
    icon:
        '<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512"><path fill="currentColor" d="M256 32C132.288 32 32 132.288 32 256s100.288 224 224 224s224-100.288 224-224S379.712 32 256 32m0 64a160 160 0 1 1 0 320a160 160 0 0 1 0-320m0 64a32 32 0 1 0 0 64a32 32 0 0 0 0-64m0 192c44.112 0 80-35.888 80-80h-32a48 48 0 0 1-96 0h-32c0 44.112 35.888 80 80 80"/></svg>',
  ),
  GenreModel(
    id: 10751,
    name: "Família",
    color: const Color(0xFF2E7D32), // verde escuro
    icon:
        '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"><path fill="currentColor" d="M12 12a5 5 0 1 0-5-5a5.006 5.006 0 0 0 5 5m-7 9v-2a4 4 0 0 1 4-4h6a4 4 0 0 1 4 4v2z"/></svg>',
  ),
  GenreModel(
    id: 10762,
    name: "Crianças",
    color: const Color(0xFF1565C0), // azul escuro
    icon:
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path fill="currentColor" d="M12 12a5 5 0 1 0-5-5a5.006 5.006 0 0 0 5 5m-7 9v-2a4 4 0 0 1 4-4h6a4 4 0 0 1 4 4v2z"/></svg>',
  ),
  GenreModel(
    id: 9648,
    name: "Mistério",
    color: const Color(0xFF212121), // preto acinzentado
    icon:
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path fill="currentColor" d="M12 2a10 10 0 1 0 7.07 2.93A9.982 9.982 0 0 0 12 2m1 17h-2v-2h2Zm1.07-7.75l-.9.92A1.494 1.494 0 0 0 13 13v1h-2v-1a3.4 3.4 0 0 1 1-2.45l1.2-1.2a1.5 1.5 0 1 0-2.12-2.12a1.493 1.493 0 0 0-.44 1.06H8a3.49 3.49 0 0 1 1.03-2.47a3.503 3.503 0 0 1 4.95 0a3.5 3.5 0 0 1 .09 4.78Z"/></svg>',
  ),
  GenreModel(
    id: 10763,
    name: "Notícias",
    color: const Color(0xFF283593), // azul indigo escuro
    icon:
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path fill="currentColor" d="M21 6h-2V3H5v3H3v15h18zm-4 13H7V8h10z"/></svg>',
  ),
  GenreModel(
    id: 10764,
    name: "Reality",
    color: const Color(0xFF6D4C41), // marrom médio escuro
    icon:
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path fill="currentColor" d="M20 3H4v18h16zm-2 16H6V5h12z"/></svg>',
  ),
  GenreModel(
    id: 10765,
    name: "Sci-Fi & Fantasia",
    color: const Color(0xFF1A237E), // azul profundo
    icon:
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path fill="currentColor" d="M12 2a10 10 0 1 0 10 10A10.011 10.011 0 0 0 12 2m0 18a8 8 0 1 1 8-8a8.009 8.009 0 0 1-8 8m-1-7h2v5h-2zm0-8h2v5h-2z"/></svg>',
  ),
  GenreModel(
    id: 10766,
    name: "Telenovela",
    color: const Color(0xFF880E4F), // rosa escuro
    icon:
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path fill="currentColor" d="M4 4h16v16H4zm2 2v12h12V6z"/></svg>',
  ),
  GenreModel(
    id: 10767,
    name: "Entrevista",
    color: const Color(0xFF4A148C), // roxo escuro
    icon:
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path fill="currentColor" d="M12 2a10 10 0 1 0 10 10A10.011 10.011 0 0 0 12 2m1 14h-2v-2h2zm0-4h-2V7h2z"/></svg>',
  ),
  GenreModel(
    id: 10768,
    name: "Guerra e política",
    color: const Color(0xFF1B5E20), // verde militar escuro
    icon:
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path fill="currentColor" d="M2 12l10 9V3z"/></svg>',
  ),
  GenreModel(
    id: 37,
    name: "Faroeste",
    color: const Color(0xFF5D4037), // marrom rústico escuro
    icon:
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path fill="currentColor" d="M12 2L2 7l10 5 10-5zm0 7L2 7v10l10 5 10-5V7z"/></svg>',
  ),
];
