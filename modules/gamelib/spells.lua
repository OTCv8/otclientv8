SpelllistSettings = {
  ['Default'] = {
    iconFile = '/images/game/spells/defaultspells',
    iconSize = {width = 32, height = 32},
    spellListWidth = 210,
    spellWindowWidth = 550,
    spellOrder = {'Animate Dead', 'Annihilation', "Apprentice's Strike", 'Avalanche', 'Avatar of Balance', 'Avatar of Light', 'Avatar of Nature', 'Avatar of Steel', 'Avatar of Storm', 'Balanced Brawl', 'Berserk', 'Blood Rage', 'Brutal Strike', 'Cancel Invisibility', 'Cancel Magic Shield', 'Chained Penance', 'Challenge', 'Chameleon', 'Charge', 'Chivalrous Challenge', 'Conjure Arrow', 'Conjure Bolt', 'Conjure Explosive Arrow', 'Conjure Piercing Bolt', 'Conjure Poisoned Arrow', 'Conjure Power Bolt', 'Conjure Royal Star', 'Conjure Sniper Arrow', 'Conjure Wand of Darkness', 'Convince Creature', 'Creature Illusion', 'Cure Bleeding', 'Cure Burning', 'Cure Curse', 'Cure Electrification', 'Cure Poison', 'Cure Poison Rune', 'Curse', 'Death Strike', 'Desintegrate', 'Destroy Field', 'Devastating Knockout', 'Divine Caldera', 'Divine Dazzle', 'Divine Empowerment', 'Divine Grenade', 'Divine Healing', 'Divine Missile', 'Double Jab', 'Electrify', 'Enchant Party', 'Enchant Spear', 'Enchant Staff', 'Energy Beam', 'Energy Field', 'Energy Strike', 'Energy Wall', 'Energy Wave', 'Energybomb', 'Enlighten Party', 'Envenom', 'Eternal Winter', 'Ethereal Spear', "Executioner's Throw", 'Explosion', 'Expose Weakness', 'Fair Wound Cleansing', 'Fierce Berserk', 'Find Fiend', 'Find Person', 'Fire Field', 'Fire Wall', 'Fire Wave', 'Fireball', 'Firebomb', 'Flame Strike', 'Flurry of Blows', 'Focus Harmony', 'Focus Serenity', 'Food', 'Forceful Uppercut', 'Front Sweep', 'Great Death Beam', 'Great Energy Beam', 'Great Fire Wave', 'Great Fireball', 'Great Light', 'Greater Flurry of Blows', 'Greater Tiger Clash', 'Groundshaker', 'Haste', 'Heal Friend', 'Heal Party', 'Heavy Magic Missile', 'Hells Core', 'Holy Flash', 'Holy Missile', 'Ice Burst', 'Ice Strike', 'Ice Wave', 'Icicle', 'Ignite', 'Inflict Wound', 'Intense Healing', 'Intense Healing Rune', 'Intense Recovery', 'Intense Wound Cleansing', 'Invisibility', 'Levitate', 'Light', 'Light Healing', 'Light Magic Missile', 'Lightning', 'Magic Rope', 'Magic Shield', 'Magic Wall', 'Mass Healing', 'Mass Spirit Mend', 'Mentor Other', 'Mystic Repulse', "Nature's Embrace", 'Paralyze', 'Physical Strike', 'Poison Bomb', 'Poison Field', 'Poison Wall', 'Protect Party', 'Protector', 'Rage of the Skies', 'Recovery', 'Restoration', 'Restore Balance', 'Salvation', 'Sap Strength', 'Sharpshooter', 'Soulfire', 'Spirit Mend', 'Spiritual Outburst', 'Stalagmite', 'Stone Shower', 'Strong Energy Strike', 'Strong Ethereal Spear', 'Strong Flame Strike', 'Strong Haste', 'Strong Ice Strike', 'Strong Ice Wave', 'Strong Terra Strike', 'Sudden Death', 'Summon Creature', 'Summon Druid Familiar', 'Summon Knight Familiar', 'Summon Monk Familiar', 'Summon Paladin Familiar', 'Summon Sorcerer Familiar', 'Sweeping Takedown', 'Swift Foot', 'Swift Jab', 'Terra Burst', 'Terra Strike', 'Terra Wave', 'Thunderstorm', 'Tiger Clash', 'Train Party', 'Ultimate Energy Strike', 'Ultimate Flame Strike', 'Ultimate Healing', 'Ultimate Healing Rune', 'Ultimate Ice Strike', 'Ultimate Light', 'Ultimate Terra Strike', 'Virtue of Harmony', 'Virtue of Justice', 'Virtue of Sustain', 'Whirlwind Throw', 'Wild Growth', 'Wound Cleansing', 'Wrath of Nature'}
  }--[[,

  ['Sample'] =  {
    iconFile = '/images/game/spells/sample',
    iconSize = {width = 64, height = 64},
    spellOrder = {'Critical Strike', 'Firefly', 'Fire Breath', 'Moonglaives', 'Wind Walk'}
  }]]
}

SpellInfo = {
  ['Default'] = {
    ['Death Strike'] =             {id = 87,  words = 'exori mort',            exhaustion = 2000,  premium = true,  type = 'Instant', icon = 'deathstrike',            mana = 20,     level = 16, soul = 0, group = {[1] = 2000},               vocations = {1, 5}},
    ['Flame Strike'] =             {id = 89,  words = 'exori flam',            exhaustion = 2000,  premium = true,  type = 'Instant', icon = 'flamestrike',            mana = 20,     level = 14, soul = 0, group = {[1] = 2000},               vocations = {1, 2, 5, 6}},
    ['Strong Flame Strike'] =      {id = 150, words = 'exori gran flam',       exhaustion = 8000,  premium = true,  type = 'Instant', icon = 'strongflamestrike',      mana = 60,     level = 70, soul = 0, group = {[1] = 2000, [4] = 8000},   vocations = {1, 5}},
    ['Ultimate Flame Strike'] =    {id = 154, words = 'exori max flam',        exhaustion = 30000, premium = true,  type = 'Instant', icon = 'ultimateflamestrike',    mana = 100,    level = 90, soul = 0, group = {[1] = 4000},               vocations = {1, 5}},
    ['Energy Strike'] =            {id = 88,  words = 'exori vis',             exhaustion = 2000,  premium = true,  type = 'Instant', icon = 'energystrike',           mana = 20,     level = 12, soul = 0, group = {[1] = 2000},               vocations = {1, 2, 5, 6}},
    ['Strong Energy Strike'] =     {id = 151, words = 'exori gran vis',        exhaustion = 8000,  premium = true,  type = 'Instant', icon = 'strongenergystrike',     mana = 60,     level = 80, soul = 0, group = {[1] = 2000, [4] = 8000},   vocations = {1, 5}},
    ['Ultimate Energy Strike'] =   {id = 155, words = 'exori max vis',         exhaustion = 30000, premium = true,  type = 'Instant', icon = 'ultimateenergystrike',   mana = 100,    level = 100,soul = 0, group = {[1] = 4000},               vocations = {1, 5}},
    ['Whirlwind Throw'] =          {id = 107, words = 'exori hur',             exhaustion = 6000,  premium = true,  type = 'Instant', icon = 'whirlwindthrow',         mana = 40,     level = 28, soul = 0, group = {[1] = 2000},               vocations = {4, 8}},
    ['Fire Wave'] =                {id = 19,  words = 'exevo flam hur',        exhaustion = 4000,  premium = false, type = 'Instant', icon = 'firewave',               mana = 25,     level = 18, soul = 0, group = {[1] = 2000},               vocations = {1, 5}},
    ['Ethereal Spear'] =           {id = 111, words = 'exori con',             exhaustion = 2000,  premium = true,  type = 'Instant', icon = 'etherealspear',          mana = 25,     level = 23, soul = 0, group = {[1] = 2000},               vocations = {3, 7}},
    ['Strong Ethereal Spear'] =    {id = 57,  words = 'exori gran con',        exhaustion = 8000,  premium = true,  type = 'Instant', icon = 'strongetherealspear',    mana = 55,     level = 90, soul = 0, group = {[1] = 2000},               vocations = {3, 7}},
    ['Energy Beam'] =              {id = 22,  words = 'exevo vis lux',         exhaustion = 4000,  premium = false, type = 'Instant', icon = 'energybeam',             mana = 40,     level = 23, soul = 0, group = {[1] = 2000},               vocations = {1, 5}},
    ['Great Energy Beam'] =        {id = 23,  words = 'exevo gran vis lux',    exhaustion = 6000,  premium = false, type = 'Instant', icon = 'greatenergybeam',        mana = 110,    level = 29, soul = 0, group = {[1] = 2000},               vocations = {1, 5}},
    ['Groundshaker'] =             {id = 106, words = 'exori mas',             exhaustion = 8000,  premium = true,  type = 'Instant', icon = 'groundshaker',           mana = 160,    level = 33, soul = 0, group = {[1] = 2000},               vocations = {4, 8}},
    ['Berserk'] =                  {id = 80,  words = 'exori',                 exhaustion = 4000,  premium = true,  type = 'Instant', icon = 'berserk',                mana = 115,    level = 35, soul = 0, group = {[1] = 2000},               vocations = {4, 8}},
    ['Annihilation'] =             {id = 62,  words = 'exori gran ico',        exhaustion = 30000, premium = true,  type = 'Instant', icon = 'annihilation',           mana = 300,    level = 110,soul = 0, group = {[1] = 4000},               vocations = {4, 8}},
    ['Brutal Strike'] =            {id = 61,  words = 'exori ico',             exhaustion = 6000,  premium = true,  type = 'Instant', icon = 'brutalstrike',           mana = 30,     level = 16, soul = 0, group = {[1] = 2000},               vocations = {4, 8}},
    ['Front Sweep'] =              {id = 59,  words = 'exori min',             exhaustion = 6000,  premium = true,  type = 'Instant', icon = 'frontsweep',             mana = 200,    level = 70, soul = 0, group = {[1] = 2000},               vocations = {4, 8}},
    ['Inflict Wound'] =            {id = 141, words = 'utori kor',             exhaustion = 30000, premium = true,  type = 'Instant', icon = 'inflictwound',           mana = 30,     level = 40, soul = 0, group = {[1] = 2000},               vocations = {4, 8, 9, 10}},
    ['Ignite'] =                   {id = 138, words = 'utori flam',            exhaustion = 30000, premium = true,  type = 'Instant', icon = 'ignite',                 mana = 30,     level = 26, soul = 0, group = {[1] = 2000},               vocations = {1, 5}},
    ['Lightning'] =                {id = 149, words = 'exori amp vis',         exhaustion = 8000,  premium = true,  type = 'Instant', icon = 'lightning',              mana = 60,     level = 55, soul = 0, group = {[1] = 2000, [4] = 8000},   vocations = {1, 5}},
    ['Curse'] =                    {id = 139, words = 'utori mort',            exhaustion = 40000, premium = true,  type = 'Instant', icon = 'curse',                  mana = 30,     level = 75, soul = 0, group = {[1] = 2000},               vocations = {1, 5}},
    ['Electrify'] =                {id = 140, words = 'utori vis',             exhaustion = 30000, premium = true,  type = 'Instant', icon = 'electrify',              mana = 30,     level = 34, soul = 0, group = {[1] = 2000},               vocations = {1, 5}},
    ['Energy Wave'] =              {id = 13,  words = 'exevo vis hur',         exhaustion = 8000,  premium = false, type = 'Instant', icon = 'energywave',             mana = 170,    level = 38, soul = 0, group = {[1] = 2000},               vocations = {1, 5}},
    ['Rage of the Skies'] =        {id = 119, words = 'exevo gran mas vis',    exhaustion = 40000, premium = true,  type = 'Instant', icon = 'rageoftheskies',         mana = 600,    level = 55, soul = 0, group = {[1] = 4000},               vocations = {1, 5}},
    ['Fierce Berserk'] =           {id = 105, words = 'exori gran',            exhaustion = 6000,  premium = true,  type = 'Instant', icon = 'fierceberserk',          mana = 340,    level = 90, soul = 0, group = {[1] = 2000},               vocations = {4, 8}},
    ['Hells Core'] =               {id = 24,  words = 'exevo gran mas flam',   exhaustion = 40000, premium = true,  type = 'Instant', icon = 'hellscore',              mana = 1100,   level = 60, soul = 0, group = {[1] = 4000},               vocations = {1, 5}},
    ['Holy Flash'] =               {id = 143, words = 'utori san',             exhaustion = 40000, premium = true,  type = 'Instant', icon = 'holyflash',              mana = 30,     level = 70, soul = 0, group = {[1] = 2000},               vocations = {3, 7}},
    ['Divine Missile'] =           {id = 122, words = 'exori san',             exhaustion = 2000,  premium = true,  type = 'Instant', icon = 'divinemissile',          mana = 20,     level = 40, soul = 0, group = {[1] = 2000},               vocations = {3, 7}},
    ['Divine Caldera'] =           {id = 124, words = 'exevo mas san',         exhaustion = 4000,  premium = true,  type = 'Instant', icon = 'divinecaldera',          mana = 160,    level = 50, soul = 0, group = {[1] = 2000},               vocations = {3, 7}},
    ['Physical Strike'] =          {id = 148, words = 'exori moe ico',         exhaustion = 2000,  premium = true,  type = 'Instant', icon = 'physicalstrike',         mana = 20,     level = 16, soul = 0, group = {[1] = 2000},               vocations = {2, 6}},
    ['Eternal Winter'] =           {id = 118, words = 'exevo gran mas frigo',  exhaustion = 40000, premium = true,  type = 'Instant', icon = 'eternalwinter',          mana = 1050,   level = 60, soul = 0, group = {[1] = 4000},               vocations = {2, 6}},
    ['Ice Strike'] =               {id = 112, words = 'exori frigo',           exhaustion = 2000,  premium = true,  type = 'Instant', icon = 'icestrike',              mana = 20,     level = 15, soul = 0, group = {[1] = 2000},               vocations = {1, 5, 2, 6}},
    ['Strong Ice Strike'] =        {id = 152, words = 'exori gran frigo',      exhaustion = 8000,  premium = true,  type = 'Instant', icon = 'strongicestrike',        mana = 60,     level = 80, soul = 0, group = {[1] = 2000, [4] = 8000},   vocations = {2, 6}},
    ['Ultimate Ice Strike'] =      {id = 156, words = 'exori max frigo',       exhaustion = 30000, premium = true,  type = 'Instant', icon = 'ultimateicestrike',      mana = 100,    level = 100,soul = 0, group = {[1] = 4000},               vocations = {2, 6}},
    ['Ice Wave'] =                 {id = 121, words = 'exevo frigo hur',       exhaustion = 4000,  premium = false, type = 'Instant', icon = 'icewave',                mana = 25,     level = 18, soul = 0, group = {[1] = 2000},               vocations = {2, 6}},
    ['Strong Ice Wave'] =          {id = 43,  words = 'exevo gran frigo hur',  exhaustion = 8000,  premium = true,  type = 'Instant', icon = 'strongicewave',          mana = 170,    level = 40, soul = 0, group = {[1] = 2000},               vocations = {2, 6}},
    ['Envenom'] =                  {id = 142, words = 'utori pox',             exhaustion = 40000, premium = true,  type = 'Instant', icon = 'envenom',                mana = 30,     level = 50, soul = 0, group = {[1] = 2000},               vocations = {2, 6}},
    ['Terra Strike'] =             {id = 113, words = 'exori tera',            exhaustion = 2000,  premium = true,  type = 'Instant', icon = 'terrastrike',            mana = 20,     level = 13, soul = 0, group = {[1] = 2000},               vocations = {1, 5, 2, 6}},
    ['Strong Terra Strike'] =      {id = 153, words = 'exori gran tera',       exhaustion = 8000,  premium = true,  type = 'Instant', icon = 'strongterrastrike',      mana = 60,     level = 70, soul = 0, group = {[1] = 2000, [4] = 8000},   vocations = {2, 6}},
    ['Ultimate Terra Strike'] =    {id = 157, words = 'exori max tera',        exhaustion = 30000, premium = true,  type = 'Instant', icon = 'ultimateterrastrike',    mana = 100,    level = 90, soul = 0, group = {[1] = 4000},               vocations = {2, 6}},
    ['Terra Wave'] =               {id = 120, words = 'exevo tera hur',        exhaustion = 4000,  premium = false, type = 'Instant', icon = 'terrawave',              mana = 170,    level = 38, soul = 0, group = {[1] = 2000},               vocations = {2, 6}},
    ['Wrath of Nature'] =          {id = 56,  words = 'exevo gran mas tera',   exhaustion = 40000, premium = true,  type = 'Instant', icon = 'wrathofnature',          mana = 700,    level = 55, soul = 0, group = {[1] = 4000},               vocations = {2, 6}},
    ['Light Healing'] =            {id = 1,   words = 'exura',                 exhaustion = 1000,  premium = false, type = 'Instant', icon = 'lighthealing',           mana = 20,     level = 8,  soul = 0, group = {[2] = 1000},               vocations = {1, 2, 3, 5, 6, 7, 9, 10}},
    ['Wound Cleansing'] =          {id = 123, words = 'exura ico',             exhaustion = 1000,  premium = false, type = 'Instant', icon = 'woundcleansing',         mana = 40,     level = 8, soul = 0, group = {[2] = 1000},               vocations = {4, 8}},
    ['Intense Wound Cleansing'] =  {id = 158, words = 'exura gran ico',        exhaustion = 600000,premium = true,  type = 'Instant', icon = 'intensewoundcleansing',  mana = 200,    level = 80, soul = 0, group = {[2] = 1000},               vocations = {4, 8}},
    ['Cure Bleeding'] =            {id = 144, words = 'exana kor',             exhaustion = 6000,  premium = true,  type = 'Instant', icon = 'curebleeding',           mana = 30,     level = 45, soul = 0, group = {[2] = 1000},               vocations = {2, 4, 6, 8}},
    ['Cure Electrification'] =     {id = 146, words = 'exana vis',             exhaustion = 6000,  premium = true,  type = 'Instant', icon = 'curseelectrification',   mana = 30,     level = 22, soul = 0, group = {[2] = 1000},               vocations = {2, 6}},
    ['Cure Poison'] =              {id = 29,  words = 'exana pox',             exhaustion = 6000,  premium = false, type = 'Instant', icon = 'curepoison',             mana = 30,     level = 10, soul = 0, group = {[2] = 1000},               vocations = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}},
    ['Cure Burning'] =             {id = 145, words = 'exana flam',            exhaustion = 6000,  premium = true,  type = 'Instant', icon = 'cureburning',            mana = 30,     level = 30, soul = 0, group = {[2] = 1000},               vocations = {2, 6}},
    ['Cure Curse'] =               {id = 147, words = 'exana mort',            exhaustion = 6000,  premium = true,  type = 'Instant', icon = 'curecurse',              mana = 40,     level = 80, soul = 0, group = {[2] = 1000},               vocations = {3, 7}},
    ['Recovery'] =                 {id = 159, words = 'utura',                 exhaustion = 60000, premium = true,  type = 'Instant', icon = 'recovery',               mana = 75,     level = 50, soul = 0, group = {[2] = 1000},               vocations = {4, 8, 3, 7}},
    ['Intense Recovery'] =         {id = 160, words = 'utura gran',            exhaustion = 60000, premium = true,  type = 'Instant', icon = 'intenserecovery',        mana = 165,    level = 100,soul = 0, group = {[2] = 1000},               vocations = {4, 8, 3, 7}},
    ['Salvation'] =                {id = 36,  words = 'exura gran san',        exhaustion = 1000,  premium = true,  type = 'Instant', icon = 'salvation',              mana = 210,    level = 60, soul = 0, group = {[2] = 1000},               vocations = {3, 7}},
    ['Intense Healing'] =          {id = 2,   words = 'exura gran',            exhaustion = 1000,  premium = false, type = 'Instant', icon = 'intensehealing',         mana = 70,     level = 20, soul = 0, group = {[2] = 1000},               vocations = {1, 2, 3, 5, 6, 7, 9, 10}},
    ['Heal Friend'] =              {id = 84,  words = 'exura sio',             exhaustion = 1000,  premium = true,  type = 'Instant', icon = 'healfriend',             mana = 120,    level = 18, soul = 0, group = {[2] = 1000},               vocations = {2, 6}, parameter = true},
    ['Ultimate Healing'] =         {id = 3,   words = 'exura vita',            exhaustion = 1000,  premium = false, type = 'Instant', icon = 'ultimatehealing',        mana = 160,    level = 30, soul = 0, group = {[2] = 1000},               vocations = {1, 2, 5, 6}},
    ['Mass Healing'] =             {id = 82,  words = 'exura gran mas res',    exhaustion = 2000,  premium = true,  type = 'Instant', icon = 'masshealing',            mana = 150,    level = 36, soul = 0, group = {[2] = 1000},               vocations = {2, 6}},
    ['Divine Healing'] =           {id = 125, words = 'exura san',             exhaustion = 1000,  premium = false, type = 'Instant', icon = 'divinehealing',          mana = 160,    level = 35, soul = 0, group = {[2] = 1000},               vocations = {3, 7}},
    ['Light'] =                    {id = 10,  words = 'utevo lux',             exhaustion = 2000,  premium = false, type = 'Instant', icon = 'light',                  mana = 20,     level = 8,  soul = 0, group = {[3] = 2000},               vocations = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}},
    ['Find Person'] =              {id = 20,  words = 'exiva',                 exhaustion = 2000,  premium = false, type = 'Instant', icon = 'findperson',             mana = 20,     level = 8,  soul = 0, group = {[3] = 2000},               vocations = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}, parameter = true},
    ['Magic Rope'] =               {id = 76,  words = 'exani tera',            exhaustion = 2000,  premium = true,  type = 'Instant', icon = 'magicrope',              mana = 20,     level = 9,  soul = 0, group = {[3] = 2000},               vocations = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}},
    ['Levitate'] =                 {id = 81,  words = 'exani hur',             exhaustion = 2000,  premium = true,  type = 'Instant', icon = 'levitate',               mana = 50,     level = 12, soul = 0, group = {[3] = 2000},               vocations = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}, parameter = true},
    ['Great Light'] =              {id = 11,  words = 'utevo gran lux',        exhaustion = 2000,  premium = false, type = 'Instant', icon = 'greatlight',             mana = 60,     level = 13, soul = 0, group = {[3] = 2000},               vocations = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}},
    ['Magic Shield'] =             {id = 44,  words = 'utamo vita',            exhaustion = 14000,  premium = false, type = 'Instant', icon = 'magicshield',            mana = 50,     level = 14, soul = 0, group = {[3] = 2000},               vocations = {1, 2, 5, 6}},
    ['Haste'] =                    {id = 6,   words = 'utani hur',             exhaustion = 2000,  premium = true,  type = 'Instant', icon = 'haste',                  mana = 60,     level = 14, soul = 0, group = {[3] = 2000},               vocations = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}},
    ['Charge'] =                   {id = 131, words = 'utani tempo hur',       exhaustion = 2000,  premium = true,  type = 'Instant', icon = 'charge',                 mana = 100,    level = 25, soul = 0, group = {[3] = 2000},               vocations = {4, 8}},
    ['Swift Foot'] =               {id = 134, words = 'utamo tempo san',       exhaustion = 10000,  premium = true,  type = 'Instant', icon = 'swiftfoot',              mana = 400,    level = 55, soul = 0, group = {[1] = 10000, [3] = 2000},  vocations = {3, 7}},
    ['Challenge'] =                {id = 93,  words = 'exeta res',             exhaustion = 2000,  premium = true,  type = 'Instant', icon = 'challenge',              mana = 30,     level = 20, soul = 0, group = {[3] = 2000},               vocations = {8}},
    ['Strong Haste'] =             {id = 39,  words = 'utani gran hur',        exhaustion = 2000,  premium = true,  type = 'Instant', icon = 'stronghaste',            mana = 100,    level = 20, soul = 0, group = {[3] = 2000},               vocations = {1, 2, 5, 6, 9, 10}},
    ['Creature Illusion'] =        {id = 38,  words = 'utevo res ina',         exhaustion = 2000,  premium = false, type = 'Instant', icon = 'creatureillusion',       mana = 100,    level = 23, soul = 0, group = {[3] = 2000},               vocations = {1, 2, 5, 6}, parameter = true},
    ['Ultimate Light'] =           {id = 75,  words = 'utevo vis lux',         exhaustion = 2000,  premium = true,  type = 'Instant', icon = 'ultimatelight',          mana = 140,    level = 26, soul = 0, group = {[3] = 2000},               vocations = {1, 2, 5, 6}},
    ['Cancel Invisibility'] =      {id = 90,  words = 'exana ina',             exhaustion = 2000,  premium = true,  type = 'Instant', icon = 'cancelinvisibility',     mana = 200,    level = 26, soul = 0, group = {[3] = 2000},               vocations = {3, 7}},
    ['Invisibility'] =             {id = 45,  words = 'utana vid',             exhaustion = 2000,  premium = false, type = 'Instant', icon = 'invisible',              mana = 440,    level = 35, soul = 0, group = {[3] = 2000},               vocations = {1, 2, 5, 6}},
    ['Sharpshooter'] =             {id = 135, words = 'utito tempo san',       exhaustion = 10000,  premium = true,  type = 'Instant', icon = 'sharpshooter',           mana = 450,    level = 60, soul = 0, group = {[2] = 10000, [3] = 10000}, vocations = {3, 7}},
    ['Protector'] =                {id = 132, words = 'utamo tempo',           exhaustion = 2000,  premium = true,  type = 'Instant', icon = 'protector',              mana = 200,    level = 55, soul = 0, group = {[1] = 10000, [3] = 2000},  vocations = {4, 8}},
    ['Blood Rage'] =               {id = 133, words = 'utito tempo',           exhaustion = 2000,  premium = true,  type = 'Instant', icon = 'bloodrage',              mana = 290,    level = 60, soul = 0, group = {[3] = 2000},               vocations = {4, 8}},
    ['Train Party'] =              {id = 126, words = 'utito mas sio',         exhaustion = 2000,  premium = true,  type = 'Instant', icon = 'trainparty',             mana = 60, level = 32, soul = 0, group = {[3] = 2000},               vocations = {8}},
    ['Protect Party'] =            {id = 127, words = 'utamo mas sio',         exhaustion = 2000,  premium = true,  type = 'Instant', icon = 'protectparty',           mana = 90, level = 32, soul = 0, group = {[3] = 2000},               vocations = {7}},
    ['Heal Party'] =               {id = 128, words = 'utura mas sio',         exhaustion = 2000,  premium = true,  type = 'Instant', icon = 'healparty',              mana = 120, level = 32, soul = 0, group = {[3] = 2000},               vocations = {6}},
    ['Enchant Party'] =            {id = 129, words = 'utori mas sio',         exhaustion = 2000,  premium = true,  type = 'Instant', icon = 'enchantparty',           mana = 120, level = 32, soul = 0, group = {[3] = 2000},               vocations = {5}},
    ['Summon Creature'] =          {id = 9,   words = 'utevo res',             exhaustion = 2000,  premium = false, type = 'Instant', icon = 'summoncreature',         mana = 'Var.', level = 25, soul = 0, group = {[3] = 2000},               vocations = {1, 2, 5, 6}, parameter = true},
    ['Conjure Arrow'] =            {id = 51,  words = 'exevo con',             exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'conjurearrow',           mana = 100,    level = 13, soul = 1, group = {[3] = 2000},               vocations = {3, 7}},
    ['Food'] =                     {id = 42,  words = 'exevo pan',             exhaustion = 2000,  premium = false, type = 'Instant', icon = 'food',                   mana = 120,    level = 14, soul = 1, group = {[3] = 2000},               vocations = {2, 6}},
    ['Conjure Poisoned Arrow'] =   {id = 48,  words = 'exevo con pox',         exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'poisonedarrow',          mana = 130,    level = 16, soul = 2, group = {[3] = 2000},               vocations = {3, 7}},
    ['Conjure Bolt'] =             {id = 79,  words = 'exevo con mort',        exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'conjurebolt',            mana = 140,    level = 17, soul = 2, group = {[3] = 2000},               vocations = {3, 7}},
    ['Conjure Sniper Arrow'] =     {id = 108, words = 'exevo con hur',         exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'sniperarrow',            mana = 160,    level = 24, soul = 3, group = {[3] = 2000},               vocations = {3, 7}},
    ['Conjure Explosive Arrow'] =  {id = 49,  words = 'exevo con flam',        exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'explosivearrow',         mana = 290,    level = 25, soul = 3, group = {[3] = 2000},               vocations = {3, 7}},
    ['Conjure Piercing Bolt'] =    {id = 109, words = 'exevo con grav',        exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'piercingbolt',           mana = 180,    level = 33, soul = 3, group = {[3] = 2000},               vocations = {3, 7}},
    ['Enchant Staff'] =            {id = 92,  words = 'exeta vis',             exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'enchantstaff',           mana = 80,     level = 41, soul = 0, group = {[3] = 2000},               vocations = {5}},
    ['Enchant Spear'] =            {id = 110, words = 'exeta con',             exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'enchantspear',           mana = 350,    level = 45, soul = 3, group = {[3] = 2000},               vocations = {3, 7}},
    ['Conjure Power Bolt'] =       {id = 95,  words = 'exevo con vis',         exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'powerbolt',              mana = 700,    level = 59, soul = 3, group = {[3] = 2000},               vocations = {7}},
    ['Poison Field'] =             {id = 26,  words = 'adevo grav pox',        exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'poisonfield',            mana = 200,    level = 14, soul = 1, group = {[3] = 2000},               vocations = {1, 2, 5, 6}},
    ['Light Magic Missile'] =      {id = 7,   words = 'adori min vis',         exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'lightmagicmissile',      mana = 120,    level = 15, soul = 1, group = {[3] = 2000},               vocations = {1, 2, 5, 6}},
    ['Fire Field'] =               {id = 25,  words = 'adevo grav flam',       exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'firefield',              mana = 240,    level = 15, soul = 1, group = {[3] = 2000},               vocations = {1, 2, 5, 6}},
    ['Fireball'] =                 {id = 15,  words = 'adori flam',            exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'fireball',               mana = 460,    level = 27, soul = 3, group = {[3] = 2000},               vocations = {1, 5}},
    ['Energy Field'] =             {id = 27,  words = 'adevo grav vis',        exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'energyfield',            mana = 320,    level = 18, soul = 2, group = {[3] = 2000},               vocations = {1, 2, 5, 6}},
    ['Stalagmite'] =               {id = 77,  words = 'adori tera',            exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'stalagmite',             mana = 350,    level = 24, soul = 2, group = {[3] = 2000},               vocations = {1, 5, 2, 6}},
    ['Great Fireball'] =           {id = 16,  words = 'adori mas flam',        exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'greatfireball',          mana = 530,    level = 30, soul = 3, group = {[3] = 2000},               vocations = {1, 5}},
    ['Heavy Magic Missile'] =      {id = 8,   words = 'adori vis',             exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'heavymagicmissile',      mana = 350,    level = 25, soul = 2, group = {[3] = 2000},               vocations = {1, 5, 2, 6}},
    ['Poison Bomb'] =              {id = 91,  words = 'adevo mas pox',         exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'poisonbomb',             mana = 520,    level = 25, soul = 2, group = {[3] = 2000},               vocations = {2, 6}},
    ['Firebomb'] =                 {id = 17,  words = 'adevo mas flam',        exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'firebomb',               mana = 600,    level = 27, soul = 3, group = {[3] = 2000},               vocations = {1, 2, 5, 6}},
    ['Soulfire'] =                 {id = 50,  words = 'adevo res flam',        exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'soulfire',               mana = 420,    level = 27, soul = 3, group = {[3] = 2000},               vocations = {1, 2, 5, 6}},
    ['Poison Wall'] =              {id = 32,  words = 'adevo mas grav pox',    exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'poisonwall',             mana = 640,    level = 29, soul = 3, group = {[3] = 2000},               vocations = {1, 2, 5, 6}},
    ['Explosion'] =                {id = 18,  words = 'adevo mas hur',         exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'explosion',              mana = 570,    level = 31, soul = 3, group = {[3] = 2000},               vocations = {1, 2, 5, 6}},
    ['Fire Wall'] =                {id = 28,  words = 'adevo mas grav flam',   exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'firewall',               mana = 780,    level = 33, soul = 3, group = {[3] = 2000},               vocations = {1, 2, 5, 6}},
    ['Energybomb'] =               {id = 55,  words = 'adevo mas vis',         exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'energybomb',             mana = 880,    level = 37, soul = 5, group = {[3] = 2000},               vocations = {1, 5}},
    ['Energy Wall'] =              {id = 33,  words = 'adevo mas grav vis',    exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'energywall',             mana = 1000,   level = 41, soul = 5, group = {[3] = 2000},               vocations = {1, 2, 5, 6}},
    ['Sudden Death'] =             {id = 21,  words = 'adori gran mort',       exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'suddendeath',            mana = 985,    level = 45, soul = 5, group = {[3] = 2000},               vocations = {1, 5}},
    ['Cure Poison Rune'] =         {id = 31,  words = 'adana pox',             exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'antidote',               mana = 200,    level = 15, soul = 1, group = {[3] = 2000},               vocations = {2, 6}},
    ['Intense Healing Rune'] =     {id = 4,   words = 'adura gran',            exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'intensehealingrune',     mana = 120,    level = 15, soul = 2, group = {[3] = 2000},               vocations = {2, 6}},
    ['Ultimate Healing Rune'] =    {id = 5,   words = 'adura vita',            exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'ultimatehealingrune',    mana = 400,    level = 24, soul = 3, group = {[3] = 2000},               vocations = {2, 6}},
    ['Convince Creature'] =        {id = 12,  words = 'adeta sio',             exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'convincecreature',       mana = 200,    level = 16, soul = 3, group = {[3] = 2000},               vocations = {2, 6}},
    ['Animate Dead'] =             {id = 83,  words = 'adana mort',            exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'animatedead',            mana = 600,    level = 27, soul = 5, group = {[3] = 2000},               vocations = {1, 2, 5, 6}},
    ['Chameleon'] =                {id = 14,  words = 'adevo ina',             exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'chameleon',              mana = 600,    level = 27, soul = 2, group = {[3] = 2000},               vocations = {2, 6}},
    ['Destroy Field'] =            {id = 30,  words = 'adito grav',            exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'destroyfield',           mana = 120,    level = 17, soul = 2, group = {[3] = 2000},               vocations = {1, 2, 3, 5, 6, 7, 9, 10}},
    ['Desintegrate'] =             {id = 78,  words = 'adito tera',            exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'desintegrate',           mana = 200,    level = 21, soul = 3, group = {[3] = 2000},               vocations = {1, 2, 3, 5, 6, 7, 9, 10}},
    ['Magic Wall'] =               {id = 86,  words = 'adevo grav tera',       exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'magicwall',              mana = 750,    level = 32, soul = 5, group = {[3] = 2000},               vocations = {1, 5}},
    ['Wild Growth'] =              {id = 94,  words = 'adevo grav vita',       exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'wildgrowth',             mana = 600,    level = 27, soul = 5, group = {[3] = 2000},               vocations = {2, 6}},
    ['Paralyze'] =                 {id = 54,  words = 'adana ani',             exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'paralyze',               mana = 1400,   level = 54, soul = 3, group = {[3] = 2000},               vocations = {2, 6}},
    ['Icicle'] =                   {id = 114, words = 'adori frigo',           exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'icicle',                 mana = 460,    level = 28, soul = 3, group = {[3] = 2000},               vocations = {2, 6}},
    ['Avalanche'] =                {id = 115, words = 'adori mas frigo',       exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'avalanche',              mana = 530,    level = 30, soul = 3, group = {[3] = 2000},               vocations = {2, 6}},
    ['Stone Shower'] =             {id = 116, words = 'adori mas tera',        exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'stoneshower',            mana = 430,    level = 28, soul = 3, group = {[3] = 2000},               vocations = {2, 6}},
    ['Thunderstorm'] =             {id = 117, words = 'adori mas vis',         exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'thunderstorm',           mana = 430,    level = 28, soul = 3, group = {[3] = 2000},               vocations = {1, 5}},
    ['Holy Missile'] =             {id = 130, words = 'adori san',             exhaustion = 2000,  premium = false, type = 'Conjure', icon = 'holymissile',            mana = 300,    level = 27, soul = 3, group = {[3] = 2000},               vocations = {3, 7}},
    -- newest tibia spells
    ['Summon Paladin Familiar'] =  {id = 195, words = 'utevo gran res sac',    exhaustion = 1800000,premium = true, type = 'Instant', icon = 'summonpaladinfamiliar',  mana = 2000,   level = 200,soul = 0, group = {[3] = 2000},               vocations = {7}},
    ['Summon Knight Familiar'] =   {id = 194, words = 'utevo gran res eq',     exhaustion = 1800000,premium = true, type = 'Instant', icon = 'summonknightfamiliar',   mana = 1000,   level = 200,soul = 0, group = {[3] = 2000},               vocations = {8}},
    ['Summon Druid Familiar'] =    {id = 197, words = 'utevo gran res dru',    exhaustion = 1800000,premium = true, type = 'Instant', icon = 'summondruidfamiliar',    mana = 3000,   level = 200,soul = 0, group = {[3] = 2000},              vocations = {6}},
    ['Summon Sorcerer Familiar'] = {id = 196, words = 'utevo gran res ven',     exhaustion = 1800000,premium = true, type = 'Instant', icon = 'summonsorcererfamiliar', mana = 3000,   level = 200,soul = 0, group = {[3] = 2000},                vocations = {5}},
    ['Chivalrous Challenge'] =     {id = 237, words = "exeta amp res",         exhaustion = 2000,  premium = true,  type = 'Instant', icon = 'chivalrouschallange',    mana = 80,     level = 150,soul = 0, group = {[3] = 2000},               vocations = {8}},
    ['Fair Wound Cleansing'] =     {id = 239, words = 'exura med ico',         exhaustion = 1000,  premium = true,  type = 'Instant', icon = 'fairwoundcleansing',     mana = 90,     level = 300,soul = 0, group = {[2] = 1000},               vocations = {8}},
    ['Conjure Wand of Darkness'] = {id = 92, words = 'exevo gran mort',        exhaustion = 1800000,premium = true, type = 'Conjure', icon = 'conjurewandofdarkness',  mana = 250,    level = 41, soul = 0, group = {[3] = 2000},               vocations = {1, 5}},
    ['Expose Weakness'] =          {id = 243, words = 'exori moe',             exhaustion = 12000, premium = true,  type = 'Instant', icon = 'exposeweakness',        mana = 400,    level = 275,soul = 0, group = {[5] = 12000, [3] = 2000},  vocations = {1, 5}},
    ['Sap Strength'] =             {id = 244, words = 'exori kor',             exhaustion = 12000, premium = true,  type = 'Instant', icon = 'sapstrenght',           mana = 300,    level = 275,soul = 0, group = {[5] = 12000, [3] = 2000},  vocations = {1, 5}},
    ['Great Fire Wave'] =          {id = 240, words = 'exevo gran flam hur',   exhaustion = 4000,  premium = true,  type = 'Instant', icon = 'greatfirewave',         mana = 120,    level = 38, soul = 0, group = {[1] = 2000},               vocations = {1, 5}},
    ['Restoration'] =              {id = 241, words = "exura max vita",        exhaustion = 6000,  premium = true,  type = 'Instant', icon = 'restoration',            mana = 260,    level = 300,soul = 0, group = {[2] = 1000},               vocations = {1, 2, 5, 6}},
    ["Nature's Embrace"] =         {id = 242, words = 'exura gran sio',        exhaustion = 60000, premium = true,  type = 'Instant', icon = 'naturesembrace',         mana = 400,    level = 300,soul = 0, group = {[2] = 1000},               vocations = {2, 6}, parameter = true},
    ['Divine Dazzle'] =            {id = 238, words = 'exana amp res',         exhaustion = 16000, premium = true,  type = 'Instant', icon = 'divinedazzle',           mana = 80,     level = 250,soul = 0, group = {[3] = 2000},               vocations = {3, 7}},


    -- monk
    ['Spirit Mend'] = {id = 273, words = 'exura gran tio', exhaustion = 1000, premium = true, type = 'Instant', icon = 'spiritmend', mana = 210, level = 80, soul = 0, group = {[2] = 1000}, vocations = {9, 10}},
    ['Virtue of Harmony'] = {id = 274, words = 'utori virtu', exhaustion = 10000, premium = true, type = 'Instant', icon = 'virtueofharmony', mana = 210, level = 20, soul = 0, group = {[3] = 2000}, vocations = {9, 10}},
    ['Virtue of Justice'] = {id = 275, words = 'utito virtu', exhaustion = 10000, premium = true, type = 'Instant', icon = 'virtueofjustice', mana = 210, level = 20, soul = 0, group = {[3] = 2000}, vocations = {9, 10}},
    ['Virtue of Sustain'] = {id = 276, words = 'utura tio', exhaustion = 10000, premium = true, type = 'Instant', icon = 'virtueofsustain', mana = 210, level = 20, soul = 0, group = {[3] = 2000}, vocations = {9, 10}},
    ['Mentor Other'] = {id = 277, words = 'uteta tio', exhaustion = 50000, premium = true, type = 'Instant', icon = 'mentorother', mana = 110, level = 150, soul = 0, group = {[3] = 2000}, vocations = {9, 10}},
    ['Enlighten Party'] = {id = 278, words = 'utevo mas sio', exhaustion = 300000, premium = true, type = 'Instant', icon = 'enlightenparty', mana = 120, level = 32, soul = 0, group = {[3] = 2000}, vocations = {9, 10}},
    ['Focus Harmony'] = {id = 279, words = 'utevo nia', exhaustion = 120000, premium = true, type = 'Instant', icon = 'focusharmony', mana = 500, level = 275, soul = 0, group = {[3] = 2000}, vocations = {9, 10}},
    ['Balanced Brawl'] = {id = 280, words = 'exori mas res', exhaustion = 10000, premium = true, type = 'Instant', icon = 'balancedbrawl', mana = 80, level = 175, soul = 0, group = {[3] = 2000}, vocations = {9, 10}},
    ['Focus Serenity'] = {id = 281, words = 'utamo tio', exhaustion = 600000, premium = true, type = 'Instant', icon = 'focusserenity', mana = 500, level = 150, soul = 0, group = {[3] = 2000}, vocations = {9, 10}},
    ['Summon Monk Familiar'] = {id = 282, words = 'utevo gran res tio', exhaustion = 1800000, premium = true, type = 'Instant', icon = 'summonmonkfamiliar', mana = 1500, level = 200, soul = 0, group = {[3] = 2000}, vocations = {9, 10}},
    ['Avatar of Balance'] = {id = 283, words = 'uteta res tio', exhaustion = 7200000, premium = true, type = 'Instant', icon = 'avatarofbalance', mana = 1200, level = 300, soul = 0, group = {[3] = 2000}, vocations = {9, 10}},
    ['Swift Jab'] = {id = 284, words = 'exori infir pug', exhaustion = 2000, premium = false, type = 'Instant', icon = 'swiftjab', mana = 3, level = 0, soul = 0, group = {[1] = 2000}, vocations = {9, 10}},
    ['Double Jab'] = {id = 285, words = 'exori pug', exhaustion = 4000, premium = false, type = 'Instant', icon = 'doublejab', mana = 30, level = 14, soul = 0, group = {[1] = 2000}, vocations = {9, 10}},
    ['Forceful Uppercut'] = {id = 286, words = 'exori gran pug', exhaustion = 60000, premium = true, type = 'Instant', icon = 'forcefuluppercut', mana = 325, level = 110, soul = 0, group = {[1] = 2000}, vocations = {9, 10}},
    ['Flurry of Blows'] = {id = 287, words = 'exori mas pug', exhaustion = 4000, premium = true, type = 'Instant', icon = 'flurryofblows', mana = 110, level = 35, soul = 0, group = {[1] = 2000}, vocations = {9, 10}},
    ['Chained Penance'] = {id = 288, words = 'exori med pug', exhaustion = 4000, premium = true, type = 'Instant', icon = 'chainedpenance', mana = 180, level = 70, soul = 0, group = {[1] = 2000}, vocations = {9, 10}},
    ['Greater Flurry of Blows'] = {id = 289, words = 'exori gran mas pug', exhaustion = 16000, premium = true, type = 'Instant', icon = 'greaterflurryofblows', mana = 300, level = 90, soul = 0, group = {[1] = 2000}, vocations = {9, 10}},
    ['Mystic Repulse'] = {id = 290, words = 'exori amp pug', exhaustion = 20000, premium = true, type = 'Instant', icon = 'mysticrepulse', mana = 150, level = 30, soul = 0, group = {[1] = 2000}, vocations = {9, 10}},
    ['Tiger Clash'] = {id = 291, words = 'exori infir nia', exhaustion = 8000, premium = false, type = 'Instant', icon = 'tigerclash', mana = 3, level = 0, soul = 0, group = {[1] = 2000}, vocations = {9, 10}},
    ['Greater Tiger Clash'] = {id = 292, words = 'exori nia', exhaustion = 8000, premium = true, type = 'Instant', icon = 'greatertigerclash', mana = 50, level = 18, soul = 0, group = {[1] = 2000}, vocations = {9, 10}},
    ['Devastating Knockout'] = {id = 293, words = 'exori gran nia', exhaustion = 24000, premium = true, type = 'Instant', icon = 'devastatingknockout', mana = 210, level = 125, soul = 0, group = {[1] = 2000}, vocations = {9, 10}},
    ['Sweeping Takedown'] = {id = 294, words = 'exori mas nia', exhaustion = 8000, premium = true, type = 'Instant', icon = 'sweepingtakedown', mana = 210, level = 60, soul = 0, group = {[1] = 2000}, vocations = {9, 10}},
    ['Spiritual Outburst'] = {id = 295, words = 'exori gran mas nia', exhaustion = 24000, premium = true, type = 'Instant', icon = 'spiritualoutburst', mana = 425, level = 0, soul = 0, group = {[1] = 2000}, vocations = {9, 10}},
    ['Mass Spirit Mend'] = {id = 296, words = 'exura mas nia', exhaustion = 8000, premium = true, type = 'Instant', icon = 'massspiritmend', mana = 250, level = 150, soul = 0, group = {[2] = 1000}, vocations = {9, 10}},
    ['Restore Balance'] = {id = 297, words = 'exura tio sio', exhaustion = 2000, premium = true, type = 'Instant', icon = 'restorebalance', mana = 120, level = 18, soul = 0, group = {[2] = 1000}, vocations = {9, 10}},
    -- newer tibia spells from Canary (placeholder icons in defaultspells.png, slots 170+)
    ['Avatar of Steel'] = {id = 264, words = 'uteta res eq', exhaustion = 7200000, premium = true, type = 'Instant', icon = 'avatarofsteel', mana = 800, level = 300, soul = 0, group = {[3] = 2000}, vocations = {4, 8}},
    ['Avatar of Light'] = {id = 265, words = 'uteta res sac', exhaustion = 7200000, premium = true, type = 'Instant', icon = 'avataroflight', mana = 1500, level = 300, soul = 0, group = {[3] = 2000}, vocations = {3, 7}},
    ['Avatar of Storm'] = {id = 266, words = 'uteta res ven', exhaustion = 7200000, premium = true, type = 'Instant', icon = 'avatarofstorm', mana = 2200, level = 300, soul = 0, group = {[3] = 2000}, vocations = {1, 5}},
    ['Avatar of Nature'] = {id = 267, words = 'uteta res dru', exhaustion = 7200000, premium = true, type = 'Instant', icon = 'avatarofnature', mana = 2200, level = 300, soul = 0, group = {[3] = 2000}, vocations = {2, 6}},
    ['Divine Grenade'] = {id = 258, words = 'exevo tempo mas san', exhaustion = 6000, premium = true, type = 'Instant', icon = 'divinegrenade', mana = 160, level = 300, soul = 0, group = {[1] = 2000}, vocations = {3, 7}},
    ['Great Death Beam'] = {id = 260, words = 'exevo max mort', exhaustion = 10000, premium = false, type = 'Instant', icon = 'greatdeathbeam', mana = 140, level = 300, soul = 0, group = {[1] = 2000}, vocations = {1, 5}},
    ["Executioner's Throw"] = {id = 261, words = 'exori amp kor', exhaustion = 18000, premium = true, type = 'Instant', icon = 'executionersthrow', mana = 225, level = 300, soul = 0, group = {[1] = 2000}, vocations = {4, 8}},
    ['Ice Burst'] = {id = 262, words = 'exevo ulus frigo', exhaustion = 22000, premium = true, type = 'Instant', icon = 'iceburst', mana = 230, level = 300, soul = 0, group = {[1] = 2000}, vocations = {2, 6}},
    ['Terra Burst'] = {id = 263, words = 'exevo ulus tera', exhaustion = 22000, premium = true, type = 'Instant', icon = 'terraburst', mana = 230, level = 300, soul = 0, group = {[1] = 2000}, vocations = {2, 6}},
    ['Divine Empowerment'] = {id = 268, words = 'utevo grav san', exhaustion = 32000, premium = true, type = 'Instant', icon = 'divineempowerment', mana = 500, level = 300, soul = 0, group = {[3] = 2000}, vocations = {3, 7}},
    ['Cancel Magic Shield'] = {id = 245, words = 'exana vita', exhaustion = 2000, premium = false, type = 'Instant', icon = 'cancelmagicshield', mana = 50, level = 14, soul = 0, group = {[3] = 2000}, vocations = {1, 2, 5, 6}},
    ['Find Fiend'] = {id = 248, words = 'exiva moe res', exhaustion = 2000, premium = false, type = 'Instant', icon = 'findfiend', mana = 20, level = 25, soul = 0, group = {[3] = 2000}, vocations = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}},
    ['Conjure Royal Star'] = {id = 191, words = 'exevo gran con grav', exhaustion = 2000, premium = true, type = 'Conjure', icon = 'conjureroyalstar', mana = 1000, level = 150, soul = 0, group = {[3] = 2000}, vocations = {3, 7}},
    ["Apprentice's Strike"] = {id = 169, words = 'exori min flam', exhaustion = 2000, premium = false, type = 'Instant', icon = 'apprenticesstrike', mana = 6, level = 8, soul = 0, group = {[1] = 2000}, vocations = {1, 2, 5, 6}},
  }--[[,

  ['Sample'] = {
    ['Wind Walk'] =                {id = 1, words = 'windwalk',        description = 'Run at enormous speed.',          exhaustion = 2000,  premium = false, type = 'Instant', icon = 1,  mana = 50,     level = 10, soul = 0, group = {[3] = 2000}, vocations = {1, 2}},
    ['Fire Breath'] =              {id = 2, words = 'firebreath',      description = 'A strong firewave.',              exhaustion = 2000,  premium = false, type = 'Instant', icon = 2,  mana = 350,    level = 27, soul = 0, group = {[1] = 2000}, vocations = {4, 8}},
    ['Moonglaives'] =              {id = 3, words = 'moonglaives',     description = 'Throw moonglaives around you.',   exhaustion = 2000,  premium = false, type = 'Instant', icon = 3,  mana = 90,     level = 55, soul = 0, group = {[1] = 2000}, vocations = {3, 7}},
    ['Critical Strike'] =          {id = 4, words = 'criticalstrike',  description = 'Land a critical strike.',         exhaustion = 2000,  premium = false, type = 'Instant', icon = 4,  mana = 350,    level = 27, soul = 0, group = {[1] = 2000}, vocations = {3, 4, 7, 8}},
    ['Firefly'] =                  {id = 5, words = 'firefly',         description = 'Summon a angry firefly',          exhaustion = 2000,  premium = false, type = 'Instant', icon = 5,  mana = 350,    level = 27, soul = 0, group = {[1] = 2000}, vocations = {1, 2, 5, 6}}
  }]]
}

-- ['const_name'] =       {client_id, TFS_id}
-- Conversion from TFS icon id to the id used by client (icons.png order)  
SpellIcons = {
  -- monk spells (placeholder icons in defaultspells.png, slots 145+)
  ['spiritmend'] = {145, 273},
  ['virtueofharmony'] = {146, 274},
  ['virtueofjustice'] = {147, 275},
  ['virtueofsustain'] = {148, 276},
  ['mentorother'] = {149, 277},
  ['enlightenparty'] = {150, 278},
  ['focusharmony'] = {151, 279},
  ['balancedbrawl'] = {152, 280},
  ['focusserenity'] = {153, 281},
  ['summonmonkfamiliar'] = {154, 282},
  ['avatarofbalance'] = {155, 283},
  ['swiftjab'] = {156, 284},
  ['doublejab'] = {157, 285},
  ['forcefuluppercut'] = {158, 286},
  ['flurryofblows'] = {159, 287},
  ['chainedpenance'] = {160, 288},
  ['greaterflurryofblows'] = {161, 289},
  ['mysticrepulse'] = {162, 290},
  ['tigerclash'] = {163, 291},
  ['greatertigerclash'] = {164, 292},
  ['devastatingknockout'] = {165, 293},
  ['sweepingtakedown'] = {166, 294},
  ['spiritualoutburst'] = {167, 295},
  ['massspiritmend'] = {168, 296},
  ['restorebalance'] = {169, 297},
  -- newer tibia spells from Canary (placeholder icons, slots 170+)
  ['avatarofsteel'] = {170, 264},
  ['avataroflight'] = {171, 265},
  ['avatarofstorm'] = {172, 266},
  ['avatarofnature'] = {173, 267},
  ['divinegrenade'] = {174, 258},
  ['greatdeathbeam'] = {175, 260},
  ['executionersthrow'] = {176, 261},
  ['iceburst'] = {177, 262},
  ['terraburst'] = {178, 263},
  ['divineempowerment'] = {179, 268},
  ['cancelmagicshield'] = {180, 245},
  ['findfiend'] = {181, 248},
  ['conjureroyalstar'] = {182, 191},
  ['apprenticesstrike'] = {183, 169},
  -- new tibia spells, server ids match Canary (opentibiabr/canary data/scripts/spells)
  ['summonsorcererfamiliar']    = {130, 196},
  ['summondruidfamiliar']       = {129, 197},
  ['summonpaladinfamiliar']     = {127, 195},
  ['summonknightfamiliar']      = {128, 194},
  ['exposeweakness']            = {134, 243},
  ['sapstrenght']               = {135, 244},
  ['restoration']               = {137, 241},
  ['fairwoundcleansing']        = {132, 239},
  ['chivalrouschallange']       = {131, 237},
  ["naturesembrace"]            = {138, 242},
  ['divinedazzle']              = {139, 238},
  ['greatfirewave']             = {136, 240},
  ['conjurewandofdarkness']     = {133, 92},
  -- old spells
  ['intenserecovery']           = {16, 160},
  ['recovery']                  = {15, 159},
  ['intensewoundcleansing']     = {4, 158},
  ['ultimateterrastrike']       = {37, 157},
  ['ultimateicestrike']         = {34, 156},
  ['ultimateenergystrike']      = {31, 155},
  ['ultimateflamestrike']       = {28, 154},
  ['strongterrastrike']         = {36, 153},
  ['strongicestrike']           = {33, 152},
  ['strongenergystrike']        = {30, 151},
  ['strongflamestrike']         = {27, 150},
  ['lightning']                 = {51, 149},
  ['physicalstrike']            = {17, 148},
  ['curecurse']                 = {11, 147},
  ['curseelectrification']      = {14, 146},
  ['cureburning']               = {13, 145},
  ['curebleeding']              = {12, 144},
  ['holyflash']                 = {53, 143},
  ['envenom']                   = {58, 142},
  ['inflictwound']              = {57, 141},
  ['electrify']                 = {56, 140},
  ['curse']                     = {54, 139},
  ['ignite']                    = {55, 138},
  -- [[ 136 / 137 Unknown ]]
  ['sharpshooter']              = {121, 135},
  ['swiftfoot']                 = {119, 134},
  ['bloodrage']                 = {96, 133},
  ['protector']                 = {122, 132},
  ['charge']                    = {98, 131},
  ['holymissile']               = {76, 130},
  ['enchantparty']              = {113, 129},
  ['healparty']                 = {126, 128},
  ['protectparty']              = {123, 127},
  ['trainparty']                = {120, 126},
  ['divinehealing']             = {2, 125},
  ['divinecaldera']             = {40, 124},
  ['woundcleansing']            = {3, 123},
  ['divinemissile']             = {39, 122},
  ['icewave']                   = {45, 121},
  ['terrawave']                 = {47, 120},
  ['rageoftheskies']            = {52, 119},
  ['eternalwinter']             = {50, 118},
  ['thunderstorm']              = {63, 117},
  ['stoneshower']               = {65, 116},
  ['avalanche']                 = {92, 115},
  ['icicle']                    = {75, 114},
  ['terrastrike']               = {35, 113},
  ['icestrike']                 = {32, 112},
  ['etherealspear']             = {18, 111},
  ['enchantspear']              = {104, 110},
  ['piercingbolt']              = {110, 109},
  ['sniperarrow']               = {112, 108},
  ['whirlwindthrow']            = {19, 107},
  ['groundshaker']              = {25, 106},
  ['fierceberserk']             = {22, 105},
  -- [[ 96 - 104 Unknown ]]
  ['powerbolt']                 = {108, 95},
  ['wildgrowth']                = {61, 94},
  ['challenge']                 = {97, 93},
  ['enchantstaff']              = {103, 92},
  ['poisonbomb']                = {70, 91},
  ['cancelinvisibility']        = {95, 90},
  ['flamestrike']               = {26, 89},
  ['energystrike']              = {29, 88},
  ['deathstrike']               = {38, 87},
  ['magicwall']                 = {72, 86},
  ['healfriend']                = {8, 84},
  ['animatedead']               = {93, 83},
  ['masshealing']               = {9, 82},
  ['levitate']                  = {125, 81},
  ['berserk']                   = {21, 80},
  ['conjurebolt']               = {107, 79},
  ['desintegrate']              = {88, 78},
  ['stalagmite']                = {66, 77},
  ['magicrope']                 = {105, 76},
  ['ultimatelight']             = {115, 75},
  -- [[ 71 - 64 TFS House Commands ]]
  -- [[ 63 - 70 Unknown ]]
  ['annihilation']              = {24, 62},
  ['brutalstrike']              = {23, 61},
  -- [[ 60 Unknown ]]
  ['frontsweep']                = {20, 59},
  -- [[ 58 Unknown ]]
  ['strongetherealspear']       = {59, 57},
  ['wrathofnature']             = {48, 56},
  ['energybomb']                = {86, 55},
  ['paralyze']                  = {71, 54},
  --  [[ 53 Unknown ]]
  --  [[ 52 TFS Retrieve Friend ]]
  ['conjurearrow']              = {106, 51},
  ['soulfire']                  = {67, 50},
  ['explosivearrow']            = {109, 49},
  ['poisonedarrow']             = {111, 48},
  -- [[ 46 / 47 Unknown ]]
  ['invisible']                 = {94, 45},
  ['magicshield']               = {124, 44},
  ['strongicewave']             = {46, 43},
  ['food']                      = {99, 42},
  -- [[ 40 / 41 Unknown ]]
  ['stronghaste']               = {102, 39},
  ['creatureillusion']          = {100, 38},
  -- [[ 37 TFS Move ]]
  ['salvation']                 = {60, 36},
  -- [[ 34 / 35 Unknown ]]
  ['energywall']                = {84, 33},
  ['poisonwall']                = {68, 32},
  ['antidote']                  = {10, 31},
  ['destroyfield']              = {87, 30},
  ['curepoison']                = {10, 29},
  ['firewall']                  = {80, 28},
  ['energyfield']               = {85, 27},
  ['poisonfield']               = {69, 26},
  ['firefield']                 = {81, 25},
  ['hellscore']                 = {49, 24},
  ['greatenergybeam']           = {42, 23},
  ['energybeam']                = {41, 22},
  ['suddendeath']               = {64, 21},
  ['findperson']                = {114, 20},
  ['firewave']                  = {44, 19},
  ['explosion']                 = {83, 18},
  ['firebomb']                  = {82, 17},
  ['greatfireball']             = {78, 16},
  ['fireball']                  = {79, 15},
  ['chameleon']                 = {91, 14},
  ['energywave']                = {43, 13},
  ['convincecreature']          = {90, 12},
  ['greatlight']                = {116, 11},
  ['light']                     = {117, 10},
  ['summoncreature']            = {118, 9},
  ['heavymagicmissile']         = {77, 8},
  ['lightmagicmissile']         = {73, 7},
  ['haste']                     = {101, 6},
  ['ultimatehealingrune']       = {62, 5},
  ['intensehealingrune']        = {74, 4},
  ['ultimatehealing']           = {1, 3},
  ['intensehealing']            = {7, 2},
  ['lighthealing']              = {6, 1},
}

VocationNames = {
  [1] = 'Sorcerer',
  [2] = 'Druid',
  [3] = 'Paladin',
  [4] = 'Knight',
  [5] = 'Master Sorcerer',
  [6] = 'Elder Druid',
  [7] = 'Royal Paladin',
  [8] = 'Elite Knight',
  [9] = 'Monk',
  [10] = 'Exalted Monk'
}

SpellGroups = {
  [1] = 'Attack',
  [2] = 'Healing',
  [3] = 'Support',
  [4] = 'Special',
  [5] = 'Cripple'
}

Spells = {}

function Spells.getClientId(spellName)
  local profile = Spells.getSpellProfileByName(spellName)

  local id = SpellInfo[profile][spellName].icon
  if not tonumber(id) and SpellIcons[id] then
    return SpellIcons[id][1]
  end
  return tonumber(id)
end

function Spells.getServerId(spellName)
  local profile = Spells.getSpellProfileByName(spellName)

  local id = SpellInfo[profile][spellName].icon
  if not tonumber(id) and SpellIcons[id] then
    return SpellIcons[id][2]
  end
  return tonumber(id)
end

function Spells.getSpellByName(name)
  return SpellInfo[Spells.getSpellProfileByName(name)][name]
end

function Spells.getSpellByWords(words)
  local words = words:lower():trim()
  for profile,data in pairs(SpellInfo) do
    for k,spell in pairs(data) do
      if spell.words == words then
        return spell, profile, k
      end
    end
  end
  return nil
end

function Spells.getSpellByIcon(iconId)
  for profile,data in pairs(SpellInfo) do
    for k,spell in pairs(data) do
      if spell.id == iconId then
        return spell, profile, k
      end
    end
  end
  return nil
end

function Spells.getSpellIconIds()
  local ids = {}
  for profile,data in pairs(SpellInfo) do
    for k,spell in pairs(data) do
      table.insert(ids, spell.id)
    end
  end
  return ids
end

function Spells.getSpellProfileById(id)
  for profile,data in pairs(SpellInfo) do
    for k,spell in pairs(data) do
      if spell.id == id then
        return profile
      end
    end
  end
  return nil
end

function Spells.getSpellProfileByWords(words)
  for profile,data in pairs(SpellInfo) do
    for k,spell in pairs(data) do
      if spell.words == words then
        return profile
      end
    end
  end
  return nil
end

function Spells.getSpellProfileByName(spellName)
  for profile,data in pairs(SpellInfo) do
    if table.findbykey(data, spellName:trim(), true) then
      return profile
    end
  end
  return nil
end

function Spells.getSpellsByVocationId(vocId)
  local spells = {}
  for profile,data in pairs(SpellInfo) do
    for k,spell in pairs(data) do
      if table.contains(spell.vocations, vocId) then
        table.insert(spells, spell)
      end
    end
  end
  return spells
end

function Spells.filterSpellsByGroups(spells, groups)
  local filtered = {}
  for v,spell in pairs(spells) do
    local spellGroups = Spells.getGroupIds(spell)
    if table.equals(spellGroups, groups) then
      table.insert(filtered, spell)
    end
  end
  return filtered
end

function Spells.getGroupIds(spell)
  local groups = {}
  for k,_ in pairs(spell.group) do
    table.insert(groups, k)
  end
  return groups
end

function Spells.getImageClip(id, profile)
  return (((id-1)%12)*SpelllistSettings[profile].iconSize.width) .. ' ' 
    .. ((math.ceil(id/12)-1)*SpelllistSettings[profile].iconSize.height) .. ' ' 
    .. SpelllistSettings[profile].iconSize.width .. ' ' 
    .. SpelllistSettings[profile].iconSize.height
end