import
  std/unicode,
  unicode_table,
  emoji_table

type
  Interval = tuple[first, last: int32]

# auxiliary function for binary search in interval table
proc bisearch(ucs: int32, table: openArray[Interval]): bool =
  var max = table.len - 1
  var min = 0
  var mid: int

  if ucs < table[0].first or ucs > table[max].last:
    return false

  while max >= min:
    mid = (min + max) div 2
    if ucs > table[mid].last:
      min = mid + 1
    elif ucs < table[mid].first:
      max = mid - 1
    else: return true

  result = false

proc wcwidth*(c: Rune, isCjk: bool = true): int =
  let ucs = c.int32
  const combining = [
    # Source: DerivedGeneralCategory-12.0.0.txt
    # Date:  2019-01-22, 08:18:28 GMT
    #
    (0x00300.int32, 0x0036f.int32),  # Combining Grave Accent  ..Combining Latin Small Le
    (0x00483.int32, 0x00489.int32),  # Combining Cyrillic Titlo..Combining Cyrillic Milli
    (0x00591.int32, 0x005bd.int32),  # Hebrew Accent Etnahta   ..Hebrew Point Meteg
    (0x005bf.int32, 0x005bf.int32),  # Hebrew Point Rafe       ..Hebrew Point Rafe
    (0x005c1.int32, 0x005c2.int32),  # Hebrew Point Shin Dot   ..Hebrew Point Sin Dot
    (0x005c4.int32, 0x005c5.int32),  # Hebrew Mark Upper Dot   ..Hebrew Mark Lower Dot
    (0x005c7.int32, 0x005c7.int32),  # Hebrew Point Qamats Qata..Hebrew Point Qamats Qata
    (0x00610.int32, 0x0061a.int32),  # Arabic Sign Sallallahou ..Arabic Small Kasra
    (0x0064b.int32, 0x0065f.int32),  # Arabic Fathatan         ..Arabic Wavy Hamza Below
    (0x00670.int32, 0x00670.int32),  # Arabic Letter Superscrip..Arabic Letter Superscrip
    (0x006d6.int32, 0x006dc.int32),  # Arabic Small High Ligatu..Arabic Small High Seen
    (0x006df.int32, 0x006e4.int32),  # Arabic Small High Rounde..Arabic Small High Madda
    (0x006e7.int32, 0x006e8.int32),  # Arabic Small High Yeh   ..Arabic Small High Noon
    (0x006ea.int32, 0x006ed.int32),  # Arabic Empty Centre Low ..Arabic Small Low Meem
    (0x00711.int32, 0x00711.int32),  # Syriac Letter Superscrip..Syriac Letter Superscrip
    (0x00730.int32, 0x0074a.int32),  # Syriac Pthaha Above     ..Syriac Barrekh
    (0x007a6.int32, 0x007b0.int32),  # Thaana Abafili          ..Thaana Sukun
    (0x007eb.int32, 0x007f3.int32),  # Nko Combining Short High..Nko Combining Double Dot
    (0x007fd.int32, 0x007fd.int32),  # Nko Dantayalan          ..Nko Dantayalan
    (0x00816.int32, 0x00819.int32),  # Samaritan Mark In       ..Samaritan Mark Dagesh
    (0x0081b.int32, 0x00823.int32),  # Samaritan Mark Epentheti..Samaritan Vowel Sign A
    (0x00825.int32, 0x00827.int32),  # Samaritan Vowel Sign Sho..Samaritan Vowel Sign U
    (0x00829.int32, 0x0082d.int32),  # Samaritan Vowel Sign Lon..Samaritan Mark Nequdaa
    (0x00859.int32, 0x0085b.int32),  # Mandaic Affrication Mark..Mandaic Gemination Mark
    (0x008d3.int32, 0x008e1.int32),  # Arabic Small Low Waw    ..Arabic Small High Sign S
    (0x008e3.int32, 0x00902.int32),  # Arabic Turned Damma Belo..Devanagari Sign Anusvara
    (0x0093a.int32, 0x0093a.int32),  # Devanagari Vowel Sign Oe..Devanagari Vowel Sign Oe
    (0x0093c.int32, 0x0093c.int32),  # Devanagari Sign Nukta   ..Devanagari Sign Nukta
    (0x00941.int32, 0x00948.int32),  # Devanagari Vowel Sign U ..Devanagari Vowel Sign Ai
    (0x0094d.int32, 0x0094d.int32),  # Devanagari Sign Virama  ..Devanagari Sign Virama
    (0x00951.int32, 0x00957.int32),  # Devanagari Stress Sign U..Devanagari Vowel Sign Uu
    (0x00962.int32, 0x00963.int32),  # Devanagari Vowel Sign Vo..Devanagari Vowel Sign Vo
    (0x00981.int32, 0x00981.int32),  # Bengali Sign Candrabindu..Bengali Sign Candrabindu
    (0x009bc.int32, 0x009bc.int32),  # Bengali Sign Nukta      ..Bengali Sign Nukta
    (0x009c1.int32, 0x009c4.int32),  # Bengali Vowel Sign U    ..Bengali Vowel Sign Vocal
    (0x009cd.int32, 0x009cd.int32),  # Bengali Sign Virama     ..Bengali Sign Virama
    (0x009e2.int32, 0x009e3.int32),  # Bengali Vowel Sign Vocal..Bengali Vowel Sign Vocal
    (0x009fe.int32, 0x009fe.int32),  # Bengali Sandhi Mark     ..Bengali Sandhi Mark
    (0x00a01.int32, 0x00a02.int32),  # Gurmukhi Sign Adak Bindi..Gurmukhi Sign Bindi
    (0x00a3c.int32, 0x00a3c.int32),  # Gurmukhi Sign Nukta     ..Gurmukhi Sign Nukta
    (0x00a41.int32, 0x00a42.int32),  # Gurmukhi Vowel Sign U   ..Gurmukhi Vowel Sign Uu
    (0x00a47.int32, 0x00a48.int32),  # Gurmukhi Vowel Sign Ee  ..Gurmukhi Vowel Sign Ai
    (0x00a4b.int32, 0x00a4d.int32),  # Gurmukhi Vowel Sign Oo  ..Gurmukhi Sign Virama
    (0x00a51.int32, 0x00a51.int32),  # Gurmukhi Sign Udaat     ..Gurmukhi Sign Udaat
    (0x00a70.int32, 0x00a71.int32),  # Gurmukhi Tippi          ..Gurmukhi Addak
    (0x00a75.int32, 0x00a75.int32),  # Gurmukhi Sign Yakash    ..Gurmukhi Sign Yakash
    (0x00a81.int32, 0x00a82.int32),  # Gujarati Sign Candrabind..Gujarati Sign Anusvara
    (0x00abc.int32, 0x00abc.int32),  # Gujarati Sign Nukta     ..Gujarati Sign Nukta
    (0x00ac1.int32, 0x00ac5.int32),  # Gujarati Vowel Sign U   ..Gujarati Vowel Sign Cand
    (0x00ac7.int32, 0x00ac8.int32),  # Gujarati Vowel Sign E   ..Gujarati Vowel Sign Ai
    (0x00acd.int32, 0x00acd.int32),  # Gujarati Sign Virama    ..Gujarati Sign Virama
    (0x00ae2.int32, 0x00ae3.int32),  # Gujarati Vowel Sign Voca..Gujarati Vowel Sign Voca
    (0x00afa.int32, 0x00aff.int32),  # Gujarati Sign Sukun     ..Gujarati Sign Two-circle
    (0x00b01.int32, 0x00b01.int32),  # Oriya Sign Candrabindu  ..Oriya Sign Candrabindu
    (0x00b3c.int32, 0x00b3c.int32),  # Oriya Sign Nukta        ..Oriya Sign Nukta
    (0x00b3f.int32, 0x00b3f.int32),  # Oriya Vowel Sign I      ..Oriya Vowel Sign I
    (0x00b41.int32, 0x00b44.int32),  # Oriya Vowel Sign U      ..Oriya Vowel Sign Vocalic
    (0x00b4d.int32, 0x00b4d.int32),  # Oriya Sign Virama       ..Oriya Sign Virama
    (0x00b56.int32, 0x00b56.int32),  # Oriya Ai Length Mark    ..Oriya Ai Length Mark
    (0x00b62.int32, 0x00b63.int32),  # Oriya Vowel Sign Vocalic..Oriya Vowel Sign Vocalic
    (0x00b82.int32, 0x00b82.int32),  # Tamil Sign Anusvara     ..Tamil Sign Anusvara
    (0x00bc0.int32, 0x00bc0.int32),  # Tamil Vowel Sign Ii     ..Tamil Vowel Sign Ii
    (0x00bcd.int32, 0x00bcd.int32),  # Tamil Sign Virama       ..Tamil Sign Virama
    (0x00c00.int32, 0x00c00.int32),  # Telugu Sign Combining Ca..Telugu Sign Combining Ca
    (0x00c04.int32, 0x00c04.int32),  # Telugu Sign Combining An..Telugu Sign Combining An
    (0x00c3e.int32, 0x00c40.int32),  # Telugu Vowel Sign Aa    ..Telugu Vowel Sign Ii
    (0x00c46.int32, 0x00c48.int32),  # Telugu Vowel Sign E     ..Telugu Vowel Sign Ai
    (0x00c4a.int32, 0x00c4d.int32),  # Telugu Vowel Sign O     ..Telugu Sign Virama
    (0x00c55.int32, 0x00c56.int32),  # Telugu Length Mark      ..Telugu Ai Length Mark
    (0x00c62.int32, 0x00c63.int32),  # Telugu Vowel Sign Vocali..Telugu Vowel Sign Vocali
    (0x00c81.int32, 0x00c81.int32),  # Kannada Sign Candrabindu..Kannada Sign Candrabindu
    (0x00cbc.int32, 0x00cbc.int32),  # Kannada Sign Nukta      ..Kannada Sign Nukta
    (0x00cbf.int32, 0x00cbf.int32),  # Kannada Vowel Sign I    ..Kannada Vowel Sign I
    (0x00cc6.int32, 0x00cc6.int32),  # Kannada Vowel Sign E    ..Kannada Vowel Sign E
    (0x00ccc.int32, 0x00ccd.int32),  # Kannada Vowel Sign Au   ..Kannada Sign Virama
    (0x00ce2.int32, 0x00ce3.int32),  # Kannada Vowel Sign Vocal..Kannada Vowel Sign Vocal
    (0x00d00.int32, 0x00d01.int32),  # Malayalam Sign Combining..Malayalam Sign Candrabin
    (0x00d3b.int32, 0x00d3c.int32),  # Malayalam Sign Vertical ..Malayalam Sign Circular
    (0x00d41.int32, 0x00d44.int32),  # Malayalam Vowel Sign U  ..Malayalam Vowel Sign Voc
    (0x00d4d.int32, 0x00d4d.int32),  # Malayalam Sign Virama   ..Malayalam Sign Virama
    (0x00d62.int32, 0x00d63.int32),  # Malayalam Vowel Sign Voc..Malayalam Vowel Sign Voc
    (0x00dca.int32, 0x00dca.int32),  # Sinhala Sign Al-lakuna  ..Sinhala Sign Al-lakuna
    (0x00dd2.int32, 0x00dd4.int32),  # Sinhala Vowel Sign Ketti..Sinhala Vowel Sign Ketti
    (0x00dd6.int32, 0x00dd6.int32),  # Sinhala Vowel Sign Diga ..Sinhala Vowel Sign Diga
    (0x00e31.int32, 0x00e31.int32),  # Thai Character Mai Han-a..Thai Character Mai Han-a
    (0x00e34.int32, 0x00e3a.int32),  # Thai Character Sara I   ..Thai Character Phinthu
    (0x00e47.int32, 0x00e4e.int32),  # Thai Character Maitaikhu..Thai Character Yamakkan
    (0x00eb1.int32, 0x00eb1.int32),  # Lao Vowel Sign Mai Kan  ..Lao Vowel Sign Mai Kan
    (0x00eb4.int32, 0x00ebc.int32),  # Lao Vowel Sign I        ..Lao Semivowel Sign Lo
    (0x00ec8.int32, 0x00ecd.int32),  # Lao Tone Mai Ek         ..Lao Niggahita
    (0x00f18.int32, 0x00f19.int32),  # Tibetan Astrological Sig..Tibetan Astrological Sig
    (0x00f35.int32, 0x00f35.int32),  # Tibetan Mark Ngas Bzung ..Tibetan Mark Ngas Bzung
    (0x00f37.int32, 0x00f37.int32),  # Tibetan Mark Ngas Bzung ..Tibetan Mark Ngas Bzung
    (0x00f39.int32, 0x00f39.int32),  # Tibetan Mark Tsa -phru  ..Tibetan Mark Tsa -phru
    (0x00f71.int32, 0x00f7e.int32),  # Tibetan Vowel Sign Aa   ..Tibetan Sign Rjes Su Nga
    (0x00f80.int32, 0x00f84.int32),  # Tibetan Vowel Sign Rever..Tibetan Mark Halanta
    (0x00f86.int32, 0x00f87.int32),  # Tibetan Sign Lci Rtags  ..Tibetan Sign Yang Rtags
    (0x00f8d.int32, 0x00f97.int32),  # Tibetan Subjoined Sign L..Tibetan Subjoined Letter
    (0x00f99.int32, 0x00fbc.int32),  # Tibetan Subjoined Letter..Tibetan Subjoined Letter
    (0x00fc6.int32, 0x00fc6.int32),  # Tibetan Symbol Padma Gda..Tibetan Symbol Padma Gda
    (0x0102d.int32, 0x01030.int32),  # Myanmar Vowel Sign I    ..Myanmar Vowel Sign Uu
    (0x01032.int32, 0x01037.int32),  # Myanmar Vowel Sign Ai   ..Myanmar Sign Dot Below
    (0x01039.int32, 0x0103a.int32),  # Myanmar Sign Virama     ..Myanmar Sign Asat
    (0x0103d.int32, 0x0103e.int32),  # Myanmar Consonant Sign M..Myanmar Consonant Sign M
    (0x01058.int32, 0x01059.int32),  # Myanmar Vowel Sign Vocal..Myanmar Vowel Sign Vocal
    (0x0105e.int32, 0x01060.int32),  # Myanmar Consonant Sign M..Myanmar Consonant Sign M
    (0x01071.int32, 0x01074.int32),  # Myanmar Vowel Sign Geba ..Myanmar Vowel Sign Kayah
    (0x01082.int32, 0x01082.int32),  # Myanmar Consonant Sign S..Myanmar Consonant Sign S
    (0x01085.int32, 0x01086.int32),  # Myanmar Vowel Sign Shan ..Myanmar Vowel Sign Shan
    (0x0108d.int32, 0x0108d.int32),  # Myanmar Sign Shan Counci..Myanmar Sign Shan Counci
    (0x0109d.int32, 0x0109d.int32),  # Myanmar Vowel Sign Aiton..Myanmar Vowel Sign Aiton
    (0x0135d.int32, 0x0135f.int32),  # Ethiopic Combining Gemin..Ethiopic Combining Gemin
    (0x01712.int32, 0x01714.int32),  # Tagalog Vowel Sign I    ..Tagalog Sign Virama
    (0x01732.int32, 0x01734.int32),  # Hanunoo Vowel Sign I    ..Hanunoo Sign Pamudpod
    (0x01752.int32, 0x01753.int32),  # Buhid Vowel Sign I      ..Buhid Vowel Sign U
    (0x01772.int32, 0x01773.int32),  # Tagbanwa Vowel Sign I   ..Tagbanwa Vowel Sign U
    (0x017b4.int32, 0x017b5.int32),  # Khmer Vowel Inherent Aq ..Khmer Vowel Inherent Aa
    (0x017b7.int32, 0x017bd.int32),  # Khmer Vowel Sign I      ..Khmer Vowel Sign Ua
    (0x017c6.int32, 0x017c6.int32),  # Khmer Sign Nikahit      ..Khmer Sign Nikahit
    (0x017c9.int32, 0x017d3.int32),  # Khmer Sign Muusikatoan  ..Khmer Sign Bathamasat
    (0x017dd.int32, 0x017dd.int32),  # Khmer Sign Atthacan     ..Khmer Sign Atthacan
    (0x0180b.int32, 0x0180d.int32),  # Mongolian Free Variation..Mongolian Free Variation
    (0x01885.int32, 0x01886.int32),  # Mongolian Letter Ali Gal..Mongolian Letter Ali Gal
    (0x018a9.int32, 0x018a9.int32),  # Mongolian Letter Ali Gal..Mongolian Letter Ali Gal
    (0x01920.int32, 0x01922.int32),  # Limbu Vowel Sign A      ..Limbu Vowel Sign U
    (0x01927.int32, 0x01928.int32),  # Limbu Vowel Sign E      ..Limbu Vowel Sign O
    (0x01932.int32, 0x01932.int32),  # Limbu Small Letter Anusv..Limbu Small Letter Anusv
    (0x01939.int32, 0x0193b.int32),  # Limbu Sign Mukphreng    ..Limbu Sign Sa-i
    (0x01a17.int32, 0x01a18.int32),  # Buginese Vowel Sign I   ..Buginese Vowel Sign U
    (0x01a1b.int32, 0x01a1b.int32),  # Buginese Vowel Sign Ae  ..Buginese Vowel Sign Ae
    (0x01a56.int32, 0x01a56.int32),  # Tai Tham Consonant Sign ..Tai Tham Consonant Sign
    (0x01a58.int32, 0x01a5e.int32),  # Tai Tham Sign Mai Kang L..Tai Tham Consonant Sign
    (0x01a60.int32, 0x01a60.int32),  # Tai Tham Sign Sakot     ..Tai Tham Sign Sakot
    (0x01a62.int32, 0x01a62.int32),  # Tai Tham Vowel Sign Mai ..Tai Tham Vowel Sign Mai
    (0x01a65.int32, 0x01a6c.int32),  # Tai Tham Vowel Sign I   ..Tai Tham Vowel Sign Oa B
    (0x01a73.int32, 0x01a7c.int32),  # Tai Tham Vowel Sign Oa A..Tai Tham Sign Khuen-lue
    (0x01a7f.int32, 0x01a7f.int32),  # Tai Tham Combining Crypt..Tai Tham Combining Crypt
    (0x01ab0.int32, 0x01abe.int32),  # Combining Doubled Circum..Combining Parentheses Ov
    (0x01b00.int32, 0x01b03.int32),  # Balinese Sign Ulu Ricem ..Balinese Sign Surang
    (0x01b34.int32, 0x01b34.int32),  # Balinese Sign Rerekan   ..Balinese Sign Rerekan
    (0x01b36.int32, 0x01b3a.int32),  # Balinese Vowel Sign Ulu ..Balinese Vowel Sign Ra R
    (0x01b3c.int32, 0x01b3c.int32),  # Balinese Vowel Sign La L..Balinese Vowel Sign La L
    (0x01b42.int32, 0x01b42.int32),  # Balinese Vowel Sign Pepe..Balinese Vowel Sign Pepe
    (0x01b6b.int32, 0x01b73.int32),  # Balinese Musical Symbol ..Balinese Musical Symbol
    (0x01b80.int32, 0x01b81.int32),  # Sundanese Sign Panyecek ..Sundanese Sign Panglayar
    (0x01ba2.int32, 0x01ba5.int32),  # Sundanese Consonant Sign..Sundanese Vowel Sign Pan
    (0x01ba8.int32, 0x01ba9.int32),  # Sundanese Vowel Sign Pam..Sundanese Vowel Sign Pan
    (0x01bab.int32, 0x01bad.int32),  # Sundanese Sign Virama   ..Sundanese Consonant Sign
    (0x01be6.int32, 0x01be6.int32),  # Batak Sign Tompi        ..Batak Sign Tompi
    (0x01be8.int32, 0x01be9.int32),  # Batak Vowel Sign Pakpak ..Batak Vowel Sign Ee
    (0x01bed.int32, 0x01bed.int32),  # Batak Vowel Sign Karo O ..Batak Vowel Sign Karo O
    (0x01bef.int32, 0x01bf1.int32),  # Batak Vowel Sign U For S..Batak Consonant Sign H
    (0x01c2c.int32, 0x01c33.int32),  # Lepcha Vowel Sign E     ..Lepcha Consonant Sign T
    (0x01c36.int32, 0x01c37.int32),  # Lepcha Sign Ran         ..Lepcha Sign Nukta
    (0x01cd0.int32, 0x01cd2.int32),  # Vedic Tone Karshana     ..Vedic Tone Prenkha
    (0x01cd4.int32, 0x01ce0.int32),  # Vedic Sign Yajurvedic Mi..Vedic Tone Rigvedic Kash
    (0x01ce2.int32, 0x01ce8.int32),  # Vedic Sign Visarga Svari..Vedic Sign Visarga Anuda
    (0x01ced.int32, 0x01ced.int32),  # Vedic Sign Tiryak       ..Vedic Sign Tiryak
    (0x01cf4.int32, 0x01cf4.int32),  # Vedic Tone Candra Above ..Vedic Tone Candra Above
    (0x01cf8.int32, 0x01cf9.int32),  # Vedic Tone Ring Above   ..Vedic Tone Double Ring A
    (0x01dc0.int32, 0x01df9.int32),  # Combining Dotted Grave A..Combining Wide Inverted
    (0x01dfb.int32, 0x01dff.int32),  # Combining Deletion Mark ..Combining Right Arrowhea
    (0x020d0.int32, 0x020f0.int32),  # Combining Left Harpoon A..Combining Asterisk Above
    (0x02cef.int32, 0x02cf1.int32),  # Coptic Combining Ni Abov..Coptic Combining Spiritu
    (0x02d7f.int32, 0x02d7f.int32),  # Tifinagh Consonant Joine..Tifinagh Consonant Joine
    (0x02de0.int32, 0x02dff.int32),  # Combining Cyrillic Lette..Combining Cyrillic Lette
    (0x0302a.int32, 0x0302d.int32),  # Ideographic Level Tone M..Ideographic Entering Ton
    (0x03099.int32, 0x0309a.int32),  # Combining Katakana-hirag..Combining Katakana-hirag
    (0x0a66f.int32, 0x0a672.int32),  # Combining Cyrillic Vzmet..Combining Cyrillic Thous
    (0x0a674.int32, 0x0a67d.int32),  # Combining Cyrillic Lette..Combining Cyrillic Payer
    (0x0a69e.int32, 0x0a69f.int32),  # Combining Cyrillic Lette..Combining Cyrillic Lette
    (0x0a6f0.int32, 0x0a6f1.int32),  # Bamum Combining Mark Koq..Bamum Combining Mark Tuk
    (0x0a802.int32, 0x0a802.int32),  # Syloti Nagri Sign Dvisva..Syloti Nagri Sign Dvisva
    (0x0a806.int32, 0x0a806.int32),  # Syloti Nagri Sign Hasant..Syloti Nagri Sign Hasant
    (0x0a80b.int32, 0x0a80b.int32),  # Syloti Nagri Sign Anusva..Syloti Nagri Sign Anusva
    (0x0a825.int32, 0x0a826.int32),  # Syloti Nagri Vowel Sign ..Syloti Nagri Vowel Sign
    (0x0a8c4.int32, 0x0a8c5.int32),  # Saurashtra Sign Virama  ..Saurashtra Sign Candrabi
    (0x0a8e0.int32, 0x0a8f1.int32),  # Combining Devanagari Dig..Combining Devanagari Sig
    (0x0a8ff.int32, 0x0a8ff.int32),  # Devanagari Vowel Sign Ay..Devanagari Vowel Sign Ay
    (0x0a926.int32, 0x0a92d.int32),  # Kayah Li Vowel Ue       ..Kayah Li Tone Calya Plop
    (0x0a947.int32, 0x0a951.int32),  # Rejang Vowel Sign I     ..Rejang Consonant Sign R
    (0x0a980.int32, 0x0a982.int32),  # Javanese Sign Panyangga ..Javanese Sign Layar
    (0x0a9b3.int32, 0x0a9b3.int32),  # Javanese Sign Cecak Telu..Javanese Sign Cecak Telu
    (0x0a9b6.int32, 0x0a9b9.int32),  # Javanese Vowel Sign Wulu..Javanese Vowel Sign Suku
    (0x0a9bc.int32, 0x0a9bd.int32),  # Javanese Vowel Sign Pepe..Javanese Consonant Sign
    (0x0a9e5.int32, 0x0a9e5.int32),  # Myanmar Sign Shan Saw   ..Myanmar Sign Shan Saw
    (0x0aa29.int32, 0x0aa2e.int32),  # Cham Vowel Sign Aa      ..Cham Vowel Sign Oe
    (0x0aa31.int32, 0x0aa32.int32),  # Cham Vowel Sign Au      ..Cham Vowel Sign Ue
    (0x0aa35.int32, 0x0aa36.int32),  # Cham Consonant Sign La  ..Cham Consonant Sign Wa
    (0x0aa43.int32, 0x0aa43.int32),  # Cham Consonant Sign Fina..Cham Consonant Sign Fina
    (0x0aa4c.int32, 0x0aa4c.int32),  # Cham Consonant Sign Fina..Cham Consonant Sign Fina
    (0x0aa7c.int32, 0x0aa7c.int32),  # Myanmar Sign Tai Laing T..Myanmar Sign Tai Laing T
    (0x0aab0.int32, 0x0aab0.int32),  # Tai Viet Mai Kang       ..Tai Viet Mai Kang
    (0x0aab2.int32, 0x0aab4.int32),  # Tai Viet Vowel I        ..Tai Viet Vowel U
    (0x0aab7.int32, 0x0aab8.int32),  # Tai Viet Mai Khit       ..Tai Viet Vowel Ia
    (0x0aabe.int32, 0x0aabf.int32),  # Tai Viet Vowel Am       ..Tai Viet Tone Mai Ek
    (0x0aac1.int32, 0x0aac1.int32),  # Tai Viet Tone Mai Tho   ..Tai Viet Tone Mai Tho
    (0x0aaec.int32, 0x0aaed.int32),  # Meetei Mayek Vowel Sign ..Meetei Mayek Vowel Sign
    (0x0aaf6.int32, 0x0aaf6.int32),  # Meetei Mayek Virama     ..Meetei Mayek Virama
    (0x0abe5.int32, 0x0abe5.int32),  # Meetei Mayek Vowel Sign ..Meetei Mayek Vowel Sign
    (0x0abe8.int32, 0x0abe8.int32),  # Meetei Mayek Vowel Sign ..Meetei Mayek Vowel Sign
    (0x0abed.int32, 0x0abed.int32),  # Meetei Mayek Apun Iyek  ..Meetei Mayek Apun Iyek
    (0x0fb1e.int32, 0x0fb1e.int32),  # Hebrew Point Judeo-spani..Hebrew Point Judeo-spani
    (0x0fe00.int32, 0x0fe0f.int32),  # Variation Selector-1    ..Variation Selector-16
    (0x0fe20.int32, 0x0fe2f.int32),  # Combining Ligature Left ..Combining Cyrillic Titlo
    (0x101fd.int32, 0x101fd.int32),  # Phaistos Disc Sign Combi..Phaistos Disc Sign Combi
    (0x102e0.int32, 0x102e0.int32),  # Coptic Epact Thousands M..Coptic Epact Thousands M
    (0x10376.int32, 0x1037a.int32),  # Combining Old Permic Let..Combining Old Permic Let
    (0x10a01.int32, 0x10a03.int32),  # Kharoshthi Vowel Sign I ..Kharoshthi Vowel Sign Vo
    (0x10a05.int32, 0x10a06.int32),  # Kharoshthi Vowel Sign E ..Kharoshthi Vowel Sign O
    (0x10a0c.int32, 0x10a0f.int32),  # Kharoshthi Vowel Length ..Kharoshthi Sign Visarga
    (0x10a38.int32, 0x10a3a.int32),  # Kharoshthi Sign Bar Abov..Kharoshthi Sign Dot Belo
    (0x10a3f.int32, 0x10a3f.int32),  # Kharoshthi Virama       ..Kharoshthi Virama
    (0x10ae5.int32, 0x10ae6.int32),  # Manichaean Abbreviation ..Manichaean Abbreviation
    (0x10d24.int32, 0x10d27.int32),  # Hanifi Rohingya Sign Har..Hanifi Rohingya Sign Tas
    (0x10f46.int32, 0x10f50.int32),  # Sogdian Combining Dot Be..Sogdian Combining Stroke
    (0x11001.int32, 0x11001.int32),  # Brahmi Sign Anusvara    ..Brahmi Sign Anusvara
    (0x11038.int32, 0x11046.int32),  # Brahmi Vowel Sign Aa    ..Brahmi Virama
    (0x1107f.int32, 0x11081.int32),  # Brahmi Number Joiner    ..Kaithi Sign Anusvara
    (0x110b3.int32, 0x110b6.int32),  # Kaithi Vowel Sign U     ..Kaithi Vowel Sign Ai
    (0x110b9.int32, 0x110ba.int32),  # Kaithi Sign Virama      ..Kaithi Sign Nukta
    (0x11100.int32, 0x11102.int32),  # Chakma Sign Candrabindu ..Chakma Sign Visarga
    (0x11127.int32, 0x1112b.int32),  # Chakma Vowel Sign A     ..Chakma Vowel Sign Uu
    (0x1112d.int32, 0x11134.int32),  # Chakma Vowel Sign Ai    ..Chakma Maayyaa
    (0x11173.int32, 0x11173.int32),  # Mahajani Sign Nukta     ..Mahajani Sign Nukta
    (0x11180.int32, 0x11181.int32),  # Sharada Sign Candrabindu..Sharada Sign Anusvara
    (0x111b6.int32, 0x111be.int32),  # Sharada Vowel Sign U    ..Sharada Vowel Sign O
    (0x111c9.int32, 0x111cc.int32),  # Sharada Sandhi Mark     ..Sharada Extra Short Vowe
    (0x1122f.int32, 0x11231.int32),  # Khojki Vowel Sign U     ..Khojki Vowel Sign Ai
    (0x11234.int32, 0x11234.int32),  # Khojki Sign Anusvara    ..Khojki Sign Anusvara
    (0x11236.int32, 0x11237.int32),  # Khojki Sign Nukta       ..Khojki Sign Shadda
    (0x1123e.int32, 0x1123e.int32),  # Khojki Sign Sukun       ..Khojki Sign Sukun
    (0x112df.int32, 0x112df.int32),  # Khudawadi Sign Anusvara ..Khudawadi Sign Anusvara
    (0x112e3.int32, 0x112ea.int32),  # Khudawadi Vowel Sign U  ..Khudawadi Sign Virama
    (0x11300.int32, 0x11301.int32),  # Grantha Sign Combining A..Grantha Sign Candrabindu
    (0x1133b.int32, 0x1133c.int32),  # Combining Bindu Below   ..Grantha Sign Nukta
    (0x11340.int32, 0x11340.int32),  # Grantha Vowel Sign Ii   ..Grantha Vowel Sign Ii
    (0x11366.int32, 0x1136c.int32),  # Combining Grantha Digit ..Combining Grantha Digit
    (0x11370.int32, 0x11374.int32),  # Combining Grantha Letter..Combining Grantha Letter
    (0x11438.int32, 0x1143f.int32),  # Newa Vowel Sign U       ..Newa Vowel Sign Ai
    (0x11442.int32, 0x11444.int32),  # Newa Sign Virama        ..Newa Sign Anusvara
    (0x11446.int32, 0x11446.int32),  # Newa Sign Nukta         ..Newa Sign Nukta
    (0x1145e.int32, 0x1145e.int32),  # Newa Sandhi Mark        ..Newa Sandhi Mark
    (0x114b3.int32, 0x114b8.int32),  # Tirhuta Vowel Sign U    ..Tirhuta Vowel Sign Vocal
    (0x114ba.int32, 0x114ba.int32),  # Tirhuta Vowel Sign Short..Tirhuta Vowel Sign Short
    (0x114bf.int32, 0x114c0.int32),  # Tirhuta Sign Candrabindu..Tirhuta Sign Anusvara
    (0x114c2.int32, 0x114c3.int32),  # Tirhuta Sign Virama     ..Tirhuta Sign Nukta
    (0x115b2.int32, 0x115b5.int32),  # Siddham Vowel Sign U    ..Siddham Vowel Sign Vocal
    (0x115bc.int32, 0x115bd.int32),  # Siddham Sign Candrabindu..Siddham Sign Anusvara
    (0x115bf.int32, 0x115c0.int32),  # Siddham Sign Virama     ..Siddham Sign Nukta
    (0x115dc.int32, 0x115dd.int32),  # Siddham Vowel Sign Alter..Siddham Vowel Sign Alter
    (0x11633.int32, 0x1163a.int32),  # Modi Vowel Sign U       ..Modi Vowel Sign Ai
    (0x1163d.int32, 0x1163d.int32),  # Modi Sign Anusvara      ..Modi Sign Anusvara
    (0x1163f.int32, 0x11640.int32),  # Modi Sign Virama        ..Modi Sign Ardhacandra
    (0x116ab.int32, 0x116ab.int32),  # Takri Sign Anusvara     ..Takri Sign Anusvara
    (0x116ad.int32, 0x116ad.int32),  # Takri Vowel Sign Aa     ..Takri Vowel Sign Aa
    (0x116b0.int32, 0x116b5.int32),  # Takri Vowel Sign U      ..Takri Vowel Sign Au
    (0x116b7.int32, 0x116b7.int32),  # Takri Sign Nukta        ..Takri Sign Nukta
    (0x1171d.int32, 0x1171f.int32),  # Ahom Consonant Sign Medi..Ahom Consonant Sign Medi
    (0x11722.int32, 0x11725.int32),  # Ahom Vowel Sign I       ..Ahom Vowel Sign Uu
    (0x11727.int32, 0x1172b.int32),  # Ahom Vowel Sign Aw      ..Ahom Sign Killer
    (0x1182f.int32, 0x11837.int32),  # Dogra Vowel Sign U      ..Dogra Sign Anusvara
    (0x11839.int32, 0x1183a.int32),  # Dogra Sign Virama       ..Dogra Sign Nukta
    (0x119d4.int32, 0x119d7.int32),  # Nandinagari Vowel Sign U..Nandinagari Vowel Sign V
    (0x119da.int32, 0x119db.int32),  # Nandinagari Vowel Sign E..Nandinagari Vowel Sign A
    (0x119e0.int32, 0x119e0.int32),  # Nandinagari Sign Virama ..Nandinagari Sign Virama
    (0x11a01.int32, 0x11a0a.int32),  # Zanabazar Square Vowel S..Zanabazar Square Vowel L
    (0x11a33.int32, 0x11a38.int32),  # Zanabazar Square Final C..Zanabazar Square Sign An
    (0x11a3b.int32, 0x11a3e.int32),  # Zanabazar Square Cluster..Zanabazar Square Cluster
    (0x11a47.int32, 0x11a47.int32),  # Zanabazar Square Subjoin..Zanabazar Square Subjoin
    (0x11a51.int32, 0x11a56.int32),  # Soyombo Vowel Sign I    ..Soyombo Vowel Sign Oe
    (0x11a59.int32, 0x11a5b.int32),  # Soyombo Vowel Sign Vocal..Soyombo Vowel Length Mar
    (0x11a8a.int32, 0x11a96.int32),  # Soyombo Final Consonant ..Soyombo Sign Anusvara
    (0x11a98.int32, 0x11a99.int32),  # Soyombo Gemination Mark ..Soyombo Subjoiner
    (0x11c30.int32, 0x11c36.int32),  # Bhaiksuki Vowel Sign I  ..Bhaiksuki Vowel Sign Voc
    (0x11c38.int32, 0x11c3d.int32),  # Bhaiksuki Vowel Sign E  ..Bhaiksuki Sign Anusvara
    (0x11c3f.int32, 0x11c3f.int32),  # Bhaiksuki Sign Virama   ..Bhaiksuki Sign Virama
    (0x11c92.int32, 0x11ca7.int32),  # Marchen Subjoined Letter..Marchen Subjoined Letter
    (0x11caa.int32, 0x11cb0.int32),  # Marchen Subjoined Letter..Marchen Vowel Sign Aa
    (0x11cb2.int32, 0x11cb3.int32),  # Marchen Vowel Sign U    ..Marchen Vowel Sign E
    (0x11cb5.int32, 0x11cb6.int32),  # Marchen Sign Anusvara   ..Marchen Sign Candrabindu
    (0x11d31.int32, 0x11d36.int32),  # Masaram Gondi Vowel Sign..Masaram Gondi Vowel Sign
    (0x11d3a.int32, 0x11d3a.int32),  # Masaram Gondi Vowel Sign..Masaram Gondi Vowel Sign
    (0x11d3c.int32, 0x11d3d.int32),  # Masaram Gondi Vowel Sign..Masaram Gondi Vowel Sign
    (0x11d3f.int32, 0x11d45.int32),  # Masaram Gondi Vowel Sign..Masaram Gondi Virama
    (0x11d47.int32, 0x11d47.int32),  # Masaram Gondi Ra-kara   ..Masaram Gondi Ra-kara
    (0x11d90.int32, 0x11d91.int32),  # Gunjala Gondi Vowel Sign..Gunjala Gondi Vowel Sign
    (0x11d95.int32, 0x11d95.int32),  # Gunjala Gondi Sign Anusv..Gunjala Gondi Sign Anusv
    (0x11d97.int32, 0x11d97.int32),  # Gunjala Gondi Virama    ..Gunjala Gondi Virama
    (0x11ef3.int32, 0x11ef4.int32),  # Makasar Vowel Sign I    ..Makasar Vowel Sign U
    (0x16af0.int32, 0x16af4.int32),  # Bassa Vah Combining High..Bassa Vah Combining High
    (0x16b30.int32, 0x16b36.int32),  # Pahawh Hmong Mark Cim Tu..Pahawh Hmong Mark Cim Ta
    (0x16f4f.int32, 0x16f4f.int32),  # Miao Sign Consonant Modi..Miao Sign Consonant Modi
    (0x16f8f.int32, 0x16f92.int32),  # Miao Tone Right         ..Miao Tone Below
    (0x1bc9d.int32, 0x1bc9e.int32),  # Duployan Thick Letter Se..Duployan Double Mark
    (0x1d167.int32, 0x1d169.int32),  # Musical Symbol Combining..Musical Symbol Combining
    (0x1d17b.int32, 0x1d182.int32),  # Musical Symbol Combining..Musical Symbol Combining
    (0x1d185.int32, 0x1d18b.int32),  # Musical Symbol Combining..Musical Symbol Combining
    (0x1d1aa.int32, 0x1d1ad.int32),  # Musical Symbol Combining..Musical Symbol Combining
    (0x1d242.int32, 0x1d244.int32),  # Combining Greek Musical ..Combining Greek Musical
    (0x1da00.int32, 0x1da36.int32),  # Signwriting Head Rim    ..Signwriting Air Sucking
    (0x1da3b.int32, 0x1da6c.int32),  # Signwriting Mouth Closed..Signwriting Excitement
    (0x1da75.int32, 0x1da75.int32),  # Signwriting Upper Body T..Signwriting Upper Body T
    (0x1da84.int32, 0x1da84.int32),  # Signwriting Location Hea..Signwriting Location Hea
    (0x1da9b.int32, 0x1da9f.int32),  # Signwriting Fill Modifie..Signwriting Fill Modifie
    (0x1daa1.int32, 0x1daaf.int32),  # Signwriting Rotation Mod..Signwriting Rotation Mod
    (0x1e000.int32, 0x1e006.int32),  # Combining Glagolitic Let..Combining Glagolitic Let
    (0x1e008.int32, 0x1e018.int32),  # Combining Glagolitic Let..Combining Glagolitic Let
    (0x1e01b.int32, 0x1e021.int32),  # Combining Glagolitic Let..Combining Glagolitic Let
    (0x1e023.int32, 0x1e024.int32),  # Combining Glagolitic Let..Combining Glagolitic Let
    (0x1e026.int32, 0x1e02a.int32),  # Combining Glagolitic Let..Combining Glagolitic Let
    (0x1e130.int32, 0x1e136.int32),  # Nyiakeng Puachue Hmong T..Nyiakeng Puachue Hmong T
    (0x1e2ec.int32, 0x1e2ef.int32),  # Wancho Tone Tup         ..Wancho Tone Koini
    (0x1e8d0.int32, 0x1e8d6.int32),  # Mende Kikakui Combining ..Mende Kikakui Combining
    (0x1e944.int32, 0x1e94a.int32),  # Adlam Alif Lengthener   ..Adlam Nukta
    (0xe0100.int32, 0xe01ef.int32),  # Variation Selector-17   ..Variation Selector-256
  ]

  # test for 8-bit control characters
  if ucs == 0: return 0
  if ucs < 32 or (ucs >= 0x7f and ucs < 0xa0): return -1

  # binary search in table of East Asian Width
  let targetTable = if isCjk:
    TABLE_F_W & TABLE_EMOJI & TABLE_A
  else:
    TABLE_F_W & TABLE_EMOJI
  if bisearch(ucs, targetTable): return 2

  # binary search in table of non-spacing characters
  if bisearch(ucs, combining): return 0

  # if we arrive here, ucs is not a combining or C0/C1 control character
  result = 1 +
    (ucs >= 0x1100 and
    (ucs <= 0x115f or                    # Hangul Jamo init. consonants
     ucs == 0x2329 or ucs == 0x232a or
    (ucs >= 0x2e80 and ucs <= 0xa4cf and
     ucs != 0x303f) or                   # CJK ... Yi
    (ucs >= 0xac00 and ucs <= 0xd7a3) or # Hangul Syllables
    (ucs >= 0xf900 and ucs <= 0xfaff) or # CJK Compatibility Ideographs
    (ucs >= 0xfe10 and ucs <= 0xfe19) or # Vertical forms
    (ucs >= 0xfe30 and ucs <= 0xfe6f) or # CJK Compatibility Forms
    (ucs >= 0xff00 and ucs <= 0xff60) or # Fullwidth Forms
    (ucs >= 0xffe0 and ucs <= 0xffe6) or
    (ucs >= 0x20000 and ucs <= 0x2fffd) or
    (ucs >= 0x30000 and ucs <= 0x3fffd))).int

proc wcswidth*(str: string, isCjk: bool = true): int =
  let splitStr: seq[Rune] = str.toRunes
  for c in splitStr:
    let w = wcwidth(c, isCjk)
    if w < 0: return -1
    else: inc(result, w)
