class AiTutor {
  AiTutor._();

  static String welcome(String code) {
    switch (code) {
      case 'ru':
        return 'Privet! Ya Zaizen AI. Mogem uchit yaponskiy: hiragana, frazy, kandzi.';
      case 'en':
        return 'Hi! I am Zaizen AI. Ask me hiragana, phrases, or kanji.';
      case 'ja':
        return 'Konnichiwa! Zaizen AI desu. Hiragana, kaiwa, kanji wo kiite kudasai.';
      default:
        return "Salom! Men Zaizen AI. Hiragana, iboralar yoki kanji so'rang.";
    }
  }

  static List<String> hints(String code) {
    switch (code) {
      case 'ru':
        return ['Kak skazat privet', 'Kak chitat あ', 'Predstavitsya'];
      case 'en':
        return ['How to say hello', 'How to read あ', 'Introduce myself'];
      case 'ja':
        return ['Aisatsu wa?', 'あ no yomikata', 'Jikoshoukai'];
      default:
        return ['Salom qanday?', 'あ qanday oqiladi?', "O'zimni tanishtirish"];
    }
  }

  static String reply(String input, String code) {
    final t = input.toLowerCase().trim();
    final hello = t.contains('salom') || t.contains('hello') || t.contains('priv') || t.contains('konnichi') || t.contains('hi') || t.contains('aisatsu');
    final a = t.contains('あ') || t.contains('hiragana') || t.contains('hira') || t.contains('oqil') || t.contains("o'qil") || t.contains('read') || t.contains('chitat') || t.contains('yomikata');
    final name = t.contains('ism') || t.contains('name') || t.contains('imya') || t.contains('tanisht') || t.contains('jikoshoukai') || t.contains('predstav');
    final thanks = t.contains('rahmat') || t.contains('thank') || t.contains('spas') || t.contains('arigatou');

    const konnichiwa = 'こんにちは (konnichiwa)';
    const ohayou = 'おはよう (ohayou)';
    const aChar = 'あ';

    switch (code) {
      case 'ru':
        if (hello) return '$konnichiwa — dnevnoe privetstvie.\n$ohayou — utrom.';
        if (a) return '$aChar chitaetsya "a". Eto pervaya hiragana. Dalshe: い (i), う (u), え (e), お (o).';
        if (name) return '私は [imya] です。 (watashi wa ... desu) — "menya zovut ...".';
        if (thanks) return 'ありがとう (arigatou) — spasibo. Vezhlivo: ありがとうございます.';
        return 'Napishite frazu ili hiraganu — razberu po chastyam.';
      case 'en':
        if (hello) return '$konnichiwa — hello.\n$ohayou — good morning.';
        if (a) return '$aChar is read "a". Next: い (i), う (u), え (e), お (o).';
        if (name) return '私は [name] です。 (watashi wa ... desu) — "My name is ...".';
        if (thanks) return 'ありがとう (arigatou) — thank you. Polite: ありがとうございます.';
        return 'Send a phrase or a hiragana character and I will break it down.';
      case 'ja':
        if (hello) return 'こんにちは wa hiruma no aisatsu. おはよう wa asa no aisatsu desu.';
        if (a) return '「あ」wa "a" to yomimasu. Tsugi wa い i, う u, え e, お o desu.';
        if (name) return '「私は【namae】です」de jikoshoukai dekimasu.';
        if (thanks) return 'ありがとう. Teinei ni wa ありがとうございます.';
        return 'Bunsho ya hiragana wo okutte kudasai. Kaisetsu shimasu.';
      default:
        if (hello) return '$konnichiwa — kunlik salom.\n$ohayou — ertalabki salom.';
        if (a) return '$aChar "a" deb oqiladi. Keyingilar: い (i), う (u), え (e), お (o).';
        if (name) return '私は [ism] です。 (watashi wa ... desu) — "Mening ismim ...".';
        if (thanks) return 'ありがとう (arigatou) — rahmat. Hurmatli: ありがとうございます.';
        return "Iborani yoki hiragana belgisini yozing — bolaklab tushuntiraman.";
    }
  }
}
