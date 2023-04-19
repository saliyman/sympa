# -*- indent-tabs-mode: nil; -*-
# vim:ft=perl:et:sw=4

# Sympa - SYsteme de Multi-Postage Automatique
#
# Copyright 2023 The Sympa Community. See the
# AUTHORS.md file at the top-level directory of this distribution and at
# <https://github.com/sympa-community/sympa.git>.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

package Sympa::CLI::upgrade::webfont;

use strict;
use warnings;
use English qw(-no_match_vars);
use IO::Scalar;

use Conf;
use Sympa::Constants;
use Sympa::Tools::File;

use parent qw(Sympa::CLI::upgrade);

use constant _options   => qw(dry-run|n);
use constant _args      => qw();
use constant _need_priv => 1;

my %fa4_fa6 = (
    '500px'                => ['500px',                  'fab'],    # f26e
    'address-book-o'       => ['address-book',           'far'],    # f2b9
    'address-card-o'       => ['address-card',           'far'],    # f2bb
    'adn'                  => ['adn',                    'fab'],    # f170
    'amazon'               => ['amazon',                 'fab'],    # f270
    'android'              => ['android',                'fab'],    # f17b
    'angellist'            => ['angellist',              'fab'],    # f209
    'apple'                => ['apple',                  'fab'],    # f179
    'area-chart'           => ['chart-area',             'fas'],    # f1fe
    'arrow-circle-o-down'  => ['arrow-alt-circle-down',  'far'],    # f358
    'arrow-circle-o-left'  => ['arrow-alt-circle-left',  'far'],    # f359
    'arrow-circle-o-right' => ['arrow-alt-circle-right', 'far'],    # f35a
    'arrow-circle-o-up'    => ['arrow-alt-circle-up',    'far'],    # f35b
    'arrows'               => ['arrows-alt',             'fas'],    # f0b2
    'arrows-alt'           => ['expand-arrows-alt',      'fas'],    # f31e
    'arrows-h'             => ['arrows-alt-h',           'fas'],    # f337
    'arrows-v'             => ['arrows-alt-v',           'fas'],    # f338
    'asl-interpreting' => ['american-sign-language-interpreting', 'fas']
    ,                                                               # f2a3
    'automobile'           => ['car',                        'fas'],    # f1b9
    'bandcamp'             => ['bandcamp',                   'fab'],    # f2d5
    'bank'                 => ['university',                 'fas'],    # f19c
    'bar-chart'            => ['chart-bar',                  'far'],    # f080
    'bar-chart-o'          => ['chart-bar',                  'far'],    # f080
    'bathtub'              => ['bath',                       'fas'],    # f2cd
    'battery'              => ['battery-full',               'fas'],    # f240
    'battery-0'            => ['battery-empty',              'fas'],    # f244
    'battery-1'            => ['battery-quarter',            'fas'],    # f243
    'battery-2'            => ['battery-half',               'fas'],    # f242
    'battery-3'            => ['battery-three-quarters',     'fas'],    # f241
    'battery-4'            => ['battery-full',               'fas'],    # f240
    'behance'              => ['behance',                    'fab'],    # f1b4
    'behance-square'       => ['behance-square',             'fab'],    # f1b5
    'bell-o'               => ['bell',                       'far'],    # f0f3
    'bell-slash-o'         => ['bell-slash',                 'far'],    # f1f6
    'bitbucket'            => ['bitbucket',                  'fab'],    # f171
    'bitbucket-square'     => ['bitbucket',                  'fab'],    # f171
    'bitcoin'              => ['btc',                        'fab'],    # f15a
    'black-tie'            => ['black-tie',                  'fab'],    # f27e
    'bluetooth'            => ['bluetooth',                  'fab'],    # f293
    'bluetooth-b'          => ['bluetooth-b',                'fab'],    # f294
    'bookmark-o'           => ['bookmark',                   'far'],    # f02e
    'btc'                  => ['btc',                        'fab'],    # f15a
    'building-o'           => ['building',                   'far'],    # f1ad
    'buysellads'           => ['buysellads',                 'fab'],    # f20d
    'cab'                  => ['taxi',                       'fas'],    # f1ba
    'calendar'             => ['calendar-alt',               'fas'],    # f073
    'calendar-check-o'     => ['calendar-check',             'far'],    # f274
    'calendar-minus-o'     => ['calendar-minus',             'far'],    # f272
    'calendar-o'           => ['calendar',                   'far'],    # f133
    'calendar-plus-o'      => ['calendar-plus',              'far'],    # f271
    'calendar-times-o'     => ['calendar-times',             'far'],    # f273
    'caret-square-o-down'  => ['caret-square-down',          'far'],    # f150
    'caret-square-o-left'  => ['caret-square-left',          'far'],    # f191
    'caret-square-o-right' => ['caret-square-right',         'far'],    # f152
    'caret-square-o-up'    => ['caret-square-up',            'far'],    # f151
    'cc'                   => ['closed-captioning',          'far'],    # f20a
    'cc-amex'              => ['cc-amex',                    'fab'],    # f1f3
    'cc-diners-club'       => ['cc-diners-club',             'fab'],    # f24c
    'cc-discover'          => ['cc-discover',                'fab'],    # f1f2
    'cc-jcb'               => ['cc-jcb',                     'fab'],    # f24b
    'cc-mastercard'        => ['cc-mastercard',              'fab'],    # f1f1
    'cc-paypal'            => ['cc-paypal',                  'fab'],    # f1f4
    'cc-stripe'            => ['cc-stripe',                  'fab'],    # f1f5
    'cc-visa'              => ['cc-visa',                    'fab'],    # f1f0
    'chain'                => ['link',                       'fas'],    # f0c1
    'chain-broken'         => ['unlink',                     'fas'],    # f127
    'check-circle-o'       => ['check-circle',               'far'],    # f058
    'check-square-o'       => ['check-square',               'far'],    # f14a
    'chrome'               => ['chrome',                     'fab'],    # f268
    'circle-o'             => ['circle',                     'far'],    # f111
    'circle-o-notch'       => ['circle-notch',               'fas'],    # f1ce
    'circle-thin'          => ['circle',                     'far'],    # f111
    'clipboard'            => ['clipboard',                  'far'],    # f328
    'clock-o'              => ['clock',                      'far'],    # f017
    'clone'                => ['clone',                      'far'],    # f24d
    'close'                => ['times',                      'fas'],    # f00d
    'cloud-download'       => ['cloud-download-alt',         'fas'],    # f381
    'cloud-upload'         => ['cloud-upload-alt',           'fas'],    # f382
    'cny'                  => ['yen-sign',                   'fas'],    # f157
    'code-fork'            => ['code-branch',                'fas'],    # f126
    'codepen'              => ['codepen',                    'fab'],    # f1cb
    'codiepie'             => ['codiepie',                   'fab'],    # f284
    'comment-o'            => ['comment',                    'far'],    # f075
    'commenting'           => ['comment-dots',               'fas'],    # f4ad
    'commenting-o'         => ['comment-dots',               'far'],    # f4ad
    'comments-o'           => ['comments',                   'far'],    # f086
    'compass'              => ['compass',                    'far'],    # f14e
    'connectdevelop'       => ['connectdevelop',             'fab'],    # f20e
    'contao'               => ['contao',                     'fab'],    # f26d
    'copyright'            => ['copyright',                  'far'],    # f1f9
    'creative-commons'     => ['creative-commons',           'fab'],    # f25e
    'credit-card'          => ['credit-card',                'far'],    # f09d
    'credit-card-alt'      => ['credit-card',                'fas'],    # f09d
    'css3'                 => ['css3',                       'fab'],    # f13c
    'cutlery'              => ['utensils',                   'fas'],    # f2e7
    'dashboard'            => ['tachometer-alt',             'fas'],    # f3fd
    'dashcube'             => ['dashcube',                   'fab'],    # f210
    'deafness'             => ['deaf',                       'fas'],    # f2a4
    'dedent'               => ['outdent',                    'fas'],    # f03b
    'delicious'            => ['delicious',                  'fab'],    # f1a5
    'deviantart'           => ['deviantart',                 'fab'],    # f1bd
    'diamond'              => ['gem',                        'far'],    # f3a5
    'digg'                 => ['digg',                       'fab'],    # f1a6
    'dollar'               => ['dollar-sign',                'fas'],    # f155
    'dot-circle-o'         => ['dot-circle',                 'far'],    # f192
    'dribbble'             => ['dribbble',                   'fab'],    # f17d
    'drivers-license'      => ['id-card',                    'fas'],    # f2c2
    'drivers-license-o'    => ['id-card',                    'far'],    # f2c2
    'dropbox'              => ['dropbox',                    'fab'],    # f16b
    'drupal'               => ['drupal',                     'fab'],    # f1a9
    'edge'                 => ['edge',                       'fab'],    # f282
    'eercast'              => ['sellcast',                   'fab'],    # f2da
    'empire'               => ['empire',                     'fab'],    # f1d1
    'envelope-o'           => ['envelope',                   'far'],    # f0e0
    'envelope-open-o'      => ['envelope-open',              'far'],    # f2b6
    'envira'               => ['envira',                     'fab'],    # f299
    'etsy'                 => ['etsy',                       'fab'],    # f2d7
    'eur'                  => ['euro-sign',                  'fas'],    # f153
    'euro'                 => ['euro-sign',                  'fas'],    # f153
    'exchange'             => ['exchange-alt',               'fas'],    # f362
    'expeditedssl'         => ['expeditedssl',               'fab'],    # f23e
    'external-link'        => ['external-link-alt',          'fas'],    # f35d
    'external-link-square' => ['external-link-square-alt',   'fas'],    # f360
    'eye'                  => ['eye',                        'far'],    # f06e
    'eye-slash'            => ['eye-slash',                  'far'],    # f070
    'eyedropper'           => ['eye-dropper',                'fas'],    # f1fb
    'fa'                   => ['font-awesome',               'fab'],    # f2b4
    'facebook'             => ['facebook-f',                 'fab'],    # f39e
    'facebook-f'           => ['facebook-f',                 'fab'],    # f39e
    'facebook-official'    => ['facebook',                   'fab'],    # f09a
    'facebook-square'      => ['facebook-square',            'fab'],    # f082
    'feed'                 => ['rss',                        'fas'],    # f09e
    'file-archive-o'       => ['file-archive',               'far'],    # f1c6
    'file-audio-o'         => ['file-audio',                 'far'],    # f1c7
    'file-code-o'          => ['file-code',                  'far'],    # f1c9
    'file-excel-o'         => ['file-excel',                 'far'],    # f1c3
    'file-image-o'         => ['file-image',                 'far'],    # f1c5
    'file-movie-o'         => ['file-video',                 'far'],    # f1c8
    'file-o'               => ['file',                       'far'],    # f15b
    'file-pdf-o'           => ['file-pdf',                   'far'],    # f1c1
    'file-photo-o'         => ['file-image',                 'far'],    # f1c5
    'file-picture-o'       => ['file-image',                 'far'],    # f1c5
    'file-powerpoint-o'    => ['file-powerpoint',            'far'],    # f1c4
    'file-sound-o'         => ['file-audio',                 'far'],    # f1c7
    'file-text'            => ['file-alt',                   'fas'],    # f15c
    'file-text-o'          => ['file-alt',                   'far'],    # f15c
    'file-video-o'         => ['file-video',                 'far'],    # f1c8
    'file-word-o'          => ['file-word',                  'far'],    # f1c2
    'file-zip-o'           => ['file-archive',               'far'],    # f1c6
    'files-o'              => ['copy',                       'far'],    # f0c5
    'firefox'              => ['firefox',                    'fab'],    # f269
    'first-order'          => ['first-order',                'fab'],    # f2b0
    'flag-o'               => ['flag',                       'far'],    # f024
    'flash'                => ['bolt',                       'fas'],    # f0e7
    'flickr'               => ['flickr',                     'fab'],    # f16e
    'floppy-o'             => ['save',                       'far'],    # f0c7
    'folder-o'             => ['folder',                     'far'],    # f07b
    'folder-open-o'        => ['folder-open',                'far'],    # f07c
    'font-awesome'         => ['font-awesome',               'fab'],    # f2b4
    'fonticons'            => ['fonticons',                  'fab'],    # f280
    'fort-awesome'         => ['fort-awesome',               'fab'],    # f286
    'forumbee'             => ['forumbee',                   'fab'],    # f211
    'foursquare'           => ['foursquare',                 'fab'],    # f180
    'free-code-camp'       => ['free-code-camp',             'fab'],    # f2c5
    'frown-o'              => ['frown',                      'far'],    # f119
    'futbol-o'             => ['futbol',                     'far'],    # f1e3
    'gbp'                  => ['pound-sign',                 'fas'],    # f154
    'ge'                   => ['empire',                     'fab'],    # f1d1
    'gear'                 => ['cog',                        'fas'],    # f013
    'gears'                => ['cogs',                       'fas'],    # f085
    'get-pocket'           => ['get-pocket',                 'fab'],    # f265
    'gg'                   => ['gg',                         'fab'],    # f260
    'gg-circle'            => ['gg-circle',                  'fab'],    # f261
    'git'                  => ['git',                        'fab'],    # f1d3
    'git-square'           => ['git-square',                 'fab'],    # f1d2
    'github'               => ['github',                     'fab'],    # f09b
    'github-alt'           => ['github-alt',                 'fab'],    # f113
    'github-square'        => ['github-square',              'fab'],    # f092
    'gitlab'               => ['gitlab',                     'fab'],    # f296
    'gittip'               => ['gratipay',                   'fab'],    # f184
    'glass'                => ['glass-martini',              'fas'],    # f000
    'glide'                => ['glide',                      'fab'],    # f2a5
    'glide-g'              => ['glide-g',                    'fab'],    # f2a6
    'google'               => ['google',                     'fab'],    # f1a0
    'google-plus'          => ['google-plus-g',              'fab'],    # f0d5
    'google-plus-circle'   => ['google-plus',                'fab'],    # f2b3
    'google-plus-official' => ['google-plus',                'fab'],    # f2b3
    'google-plus-square'   => ['google-plus-square',         'fab'],    # f0d4
    'google-wallet'        => ['google-wallet',              'fab'],    # f1ee
    'gratipay'             => ['gratipay',                   'fab'],    # f184
    'grav'                 => ['grav',                       'fab'],    # f2d6
    'group'                => ['users',                      'fas'],    # f0c0
    'hacker-news'          => ['hacker-news',                'fab'],    # f1d4
    'hand-grab-o'          => ['hand-rock',                  'far'],    # f255
    'hand-lizard-o'        => ['hand-lizard',                'far'],    # f258
    'hand-o-down'          => ['hand-point-down',            'far'],    # f0a7
    'hand-o-left'          => ['hand-point-left',            'far'],    # f0a5
    'hand-o-right'         => ['hand-point-right',           'far'],    # f0a4
    'hand-o-up'            => ['hand-point-up',              'far'],    # f0a6
    'hand-paper-o'         => ['hand-paper',                 'far'],    # f256
    'hand-peace-o'         => ['hand-peace',                 'far'],    # f25b
    'hand-pointer-o'       => ['hand-pointer',               'far'],    # f25a
    'hand-rock-o'          => ['hand-rock',                  'far'],    # f255
    'hand-scissors-o'      => ['hand-scissors',              'far'],    # f257
    'hand-spock-o'         => ['hand-spock',                 'far'],    # f259
    'hand-stop-o'          => ['hand-paper',                 'far'],    # f256
    'handshake-o'          => ['handshake',                  'far'],    # f2b5
    'hard-of-hearing'      => ['deaf',                       'fas'],    # f2a4
    'hdd-o'                => ['hdd',                        'far'],    # f0a0
    'header'               => ['heading',                    'fas'],    # f1dc
    'heart-o'              => ['heart',                      'far'],    # f004
    'hospital-o'           => ['hospital',                   'far'],    # f0f8
    'hotel'                => ['bed',                        'fas'],    # f236
    'hourglass-1'          => ['hourglass-start',            'fas'],    # f251
    'hourglass-2'          => ['hourglass-half',             'fas'],    # f252
    'hourglass-3'          => ['hourglass-end',              'fas'],    # f253
    'hourglass-o'          => ['hourglass',                  'far'],    # f254
    'houzz'                => ['houzz',                      'fab'],    # f27c
    'html5'                => ['html5',                      'fab'],    # f13b
    'id-badge'             => ['id-badge',                   'far'],    # f2c1
    'id-card-o'            => ['id-card',                    'far'],    # f2c2
    'ils'                  => ['shekel-sign',                'fas'],    # f20b
    'image'                => ['image',                      'far'],    # f03e
    'imdb'                 => ['imdb',                       'fab'],    # f2d8
    'inr'                  => ['rupee-sign',                 'fas'],    # f156
    'instagram'            => ['instagram',                  'fab'],    # f16d
    'institution'          => ['university',                 'fas'],    # f19c
    'internet-explorer'    => ['internet-explorer',          'fab'],    # f26b
    'intersex'             => ['transgender',                'fas'],    # f224
    'ioxhost'              => ['ioxhost',                    'fab'],    # f208
    'joomla'               => ['joomla',                     'fab'],    # f1aa
    'jpy'                  => ['yen-sign',                   'fas'],    # f157
    'jsfiddle'             => ['jsfiddle',                   'fab'],    # f1cc
    'keyboard-o'           => ['keyboard',                   'far'],    # f11c
    'krw'                  => ['won-sign',                   'fas'],    # f159
    'lastfm'               => ['lastfm',                     'fab'],    # f202
    'lastfm-square'        => ['lastfm-square',              'fab'],    # f203
    'leanpub'              => ['leanpub',                    'fab'],    # f212
    'legal'                => ['gavel',                      'fas'],    # f0e3
    'lemon-o'              => ['lemon',                      'far'],    # f094
    'level-down'           => ['level-down-alt',             'fas'],    # f3be
    'level-up'             => ['level-up-alt',               'fas'],    # f3bf
    'life-bouy'            => ['life-ring',                  'far'],    # f1cd
    'life-buoy'            => ['life-ring',                  'far'],    # f1cd
    'life-ring'            => ['life-ring',                  'far'],    # f1cd
    'life-saver'           => ['life-ring',                  'far'],    # f1cd
    'lightbulb-o'          => ['lightbulb',                  'far'],    # f0eb
    'line-chart'           => ['chart-line',                 'fas'],    # f201
    'linkedin'             => ['linkedin-in',                'fab'],    # f0e1
    'linkedin-square'      => ['linkedin',                   'fab'],    # f08c
    'linode'               => ['linode',                     'fab'],    # f2b8
    'linux'                => ['linux',                      'fab'],    # f17c
    'list-alt'             => ['list-alt',                   'far'],    # f022
    'long-arrow-down'      => ['long-arrow-alt-down',        'fas'],    # f309
    'long-arrow-left'      => ['long-arrow-alt-left',        'fas'],    # f30a
    'long-arrow-right'     => ['long-arrow-alt-right',       'fas'],    # f30b
    'long-arrow-up'        => ['long-arrow-alt-up',          'fas'],    # f30c
    'mail-forward'         => ['share',                      'fas'],    # f064
    'mail-reply'           => ['reply',                      'fas'],    # f3e5
    'mail-reply-all'       => ['reply-all',                  'fas'],    # f122
    'map-marker'           => ['map-marker-alt',             'fas'],    # f3c5
    'map-o'                => ['map',                        'far'],    # f279
    'maxcdn'               => ['maxcdn',                     'fab'],    # f136
    'meanpath'             => ['font-awesome',               'fab'],    # f2b4
    'medium'               => ['medium',                     'fab'],    # f23a
    'meetup'               => ['meetup',                     'fab'],    # f2e0
    'meh-o'                => ['meh',                        'far'],    # f11a
    'minus-square-o'       => ['minus-square',               'far'],    # f146
    'mixcloud'             => ['mixcloud',                   'fab'],    # f289
    'mobile'               => ['mobile-alt',                 'fas'],    # f3cd
    'mobile-phone'         => ['mobile-alt',                 'fas'],    # f3cd
    'modx'                 => ['modx',                       'fab'],    # f285
    'money'                => ['money-bill-alt',             'far'],    # f3d1
    'moon-o'               => ['moon',                       'far'],    # f186
    'mortar-board'         => ['graduation-cap',             'fas'],    # f19d
    'navicon'              => ['bars',                       'fas'],    # f0c9
    'newspaper-o'          => ['newspaper',                  'far'],    # f1ea
    'object-group'         => ['object-group',               'far'],    # f247
    'object-ungroup'       => ['object-ungroup',             'far'],    # f248
    'odnoklassniki'        => ['odnoklassniki',              'fab'],    # f263
    'odnoklassniki-square' => ['odnoklassniki-square',       'fab'],    # f264
    'opencart'             => ['opencart',                   'fab'],    # f23d
    'openid'               => ['openid',                     'fab'],    # f19b
    'opera'                => ['opera',                      'fab'],    # f26a
    'optin-monster'        => ['optin-monster',              'fab'],    # f23c
    'pagelines'            => ['pagelines',                  'fab'],    # f18c
    'paper-plane-o'        => ['paper-plane',                'far'],    # f1d8
    'paste'                => ['clipboard',                  'far'],    # f328
    'pause-circle-o'       => ['pause-circle',               'far'],    # f28b
    'paypal'               => ['paypal',                     'fab'],    # f1ed
    'pencil'               => ['pencil-alt',                 'fas'],    # f303
    'pencil-square'        => ['pen-square',                 'fas'],    # f14b
    'pencil-square-o'      => ['edit',                       'far'],    # f044
    'photo'                => ['image',                      'far'],    # f03e
    'picture-o'            => ['image',                      'far'],    # f03e
    'pie-chart'            => ['chart-pie',                  'fas'],    # f200
    'pied-piper'           => ['pied-piper',                 'fab'],    # f2ae
    'pied-piper-alt'       => ['pied-piper-alt',             'fab'],    # f1a8
    'pied-piper-pp'        => ['pied-piper-pp',              'fab'],    # f1a7
    'pinterest'            => ['pinterest',                  'fab'],    # f0d2
    'pinterest-p'          => ['pinterest-p',                'fab'],    # f231
    'pinterest-square'     => ['pinterest-square',           'fab'],    # f0d3
    'play-circle-o'        => ['play-circle',                'far'],    # f144
    'plus-square-o'        => ['plus-square',                'far'],    # f0fe
    'product-hunt'         => ['product-hunt',               'fab'],    # f288
    'qq'                   => ['qq',                         'fab'],    # f1d6
    'question-circle-o'    => ['question-circle',            'far'],    # f059
    'quora'                => ['quora',                      'fab'],    # f2c4
    'ra'                   => ['rebel',                      'fab'],    # f1d0
    'ravelry'              => ['ravelry',                    'fab'],    # f2d9
    'rebel'                => ['rebel',                      'fab'],    # f1d0
    'reddit'               => ['reddit',                     'fab'],    # f1a1
    'reddit-alien'         => ['reddit-alien',               'fab'],    # f281
    'reddit-square'        => ['reddit-square',              'fab'],    # f1a2
    'refresh'              => ['sync',                       'fas'],    # f021
    'registered'           => ['registered',                 'far'],    # f25d
    'remove'               => ['times',                      'fas'],    # f00d
    'renren'               => ['renren',                     'fab'],    # f18b
    'reorder'              => ['bars',                       'fas'],    # f0c9
    'repeat'               => ['redo',                       'fas'],    # f01e
    'resistance'           => ['rebel',                      'fab'],    # f1d0
    'rmb'                  => ['yen-sign',                   'fas'],    # f157
    'rotate-left'          => ['undo',                       'fas'],    # f0e2
    'rotate-right'         => ['redo',                       'fas'],    # f01e
    'rouble'               => ['ruble-sign',                 'fas'],    # f158
    'rub'                  => ['ruble-sign',                 'fas'],    # f158
    'ruble'                => ['ruble-sign',                 'fas'],    # f158
    'rupee'                => ['rupee-sign',                 'fas'],    # f156
    's15'                  => ['bath',                       'fas'],    # f2cd
    'safari'               => ['safari',                     'fab'],    # f267
    'scissors'             => ['cut',                        'fas'],    # f0c4
    'scribd'               => ['scribd',                     'fab'],    # f28a
    'sellsy'               => ['sellsy',                     'fab'],    # f213
    'send'                 => ['paper-plane',                'fas'],    # f1d8
    'send-o'               => ['paper-plane',                'far'],    # f1d8
    'share-square-o'       => ['share-square',               'far'],    # f14d
    'shekel'               => ['shekel-sign',                'fas'],    # f20b
    'sheqel'               => ['shekel-sign',                'fas'],    # f20b
    'shield'               => ['shield-alt',                 'fas'],    # f3ed
    'shirtsinbulk'         => ['shirtsinbulk',               'fab'],    # f214
    'sign-in'              => ['sign-in-alt',                'fas'],    # f2f6
    'sign-out'             => ['sign-out-alt',               'fas'],    # f2f5
    'signing'              => ['sign-language',              'fas'],    # f2a7
    'simplybuilt'          => ['simplybuilt',                'fab'],    # f215
    'skyatlas'             => ['skyatlas',                   'fab'],    # f216
    'skype'                => ['skype',                      'fab'],    # f17e
    'slack'                => ['slack',                      'fab'],    # f198
    'sliders'              => ['sliders-h',                  'fas'],    # f1de
    'slideshare'           => ['slideshare',                 'fab'],    # f1e7
    'smile-o'              => ['smile',                      'far'],    # f118
    'snapchat'             => ['snapchat',                   'fab'],    # f2ab
    'snapchat-ghost'       => ['snapchat-ghost',             'fab'],    # f2ac
    'snapchat-square'      => ['snapchat-square',            'fab'],    # f2ad
    'snowflake-o'          => ['snowflake',                  'far'],    # f2dc
    'soccer-ball-o'        => ['futbol',                     'far'],    # f1e3
    'sort-alpha-asc'       => ['sort-alpha-down',            'fas'],    # f15d
    'sort-alpha-desc'      => ['sort-alpha-up',              'fas'],    # f15e
    'sort-amount-asc'      => ['sort-amount-down',           'fas'],    # f160
    'sort-amount-desc'     => ['sort-amount-up',             'fas'],    # f161
    'sort-asc'             => ['sort-up',                    'fas'],    # f0de
    'sort-desc'            => ['sort-down',                  'fas'],    # f0dd
    'sort-numeric-asc'     => ['sort-numeric-down',          'fas'],    # f162
    'sort-numeric-desc'    => ['sort-numeric-up',            'fas'],    # f163
    'soundcloud'           => ['soundcloud',                 'fab'],    # f1be
    'spoon'                => ['utensil-spoon',              'fas'],    # f2e5
    'spotify'              => ['spotify',                    'fab'],    # f1bc
    'square-o'             => ['square',                     'far'],    # f0c8
    'stack-exchange'       => ['stack-exchange',             'fab'],    # f18d
    'stack-overflow'       => ['stack-overflow',             'fab'],    # f16c
    'star-half-empty'      => ['star-half',                  'far'],    # f089
    'star-half-full'       => ['star-half',                  'far'],    # f089
    'star-half-o'          => ['star-half',                  'far'],    # f089
    'star-o'               => ['star',                       'far'],    # f005
    'steam'                => ['steam',                      'fab'],    # f1b6
    'steam-square'         => ['steam-square',               'fab'],    # f1b7
    'sticky-note-o'        => ['sticky-note',                'far'],    # f249
    'stop-circle-o'        => ['stop-circle',                'far'],    # f28d
    'stumbleupon'          => ['stumbleupon',                'fab'],    # f1a4
    'stumbleupon-circle'   => ['stumbleupon-circle',         'fab'],    # f1a3
    'sun-o'                => ['sun',                        'far'],    # f185
    'superpowers'          => ['superpowers',                'fab'],    # f2dd
    'support'              => ['life-ring',                  'far'],    # f1cd
    'tablet'               => ['tablet-alt',                 'fas'],    # f3fa
    'tachometer'           => ['tachometer-alt',             'fas'],    # f3fd
    'telegram'             => ['telegram',                   'fab'],    # f2c6
    'television'           => ['tv',                         'fas'],    # f26c
    'tencent-weibo'        => ['tencent-weibo',              'fab'],    # f1d5
    'themeisle'            => ['themeisle',                  'fab'],    # f2b2
    'thermometer'          => ['thermometer-full',           'fas'],    # f2c7
    'thermometer-0'        => ['thermometer-empty',          'fas'],    # f2cb
    'thermometer-1'        => ['thermometer-quarter',        'fas'],    # f2ca
    'thermometer-2'        => ['thermometer-half',           'fas'],    # f2c9
    'thermometer-3'        => ['thermometer-three-quarters', 'fas'],    # f2c8
    'thermometer-4'        => ['thermometer-full',           'fas'],    # f2c7
    'thumb-tack'           => ['thumbtack',                  'fas'],    # f08d
    'thumbs-o-down'        => ['thumbs-down',                'far'],    # f165
    'thumbs-o-up'          => ['thumbs-up',                  'far'],    # f164
    'ticket'               => ['ticket-alt',                 'fas'],    # f3ff
    'times-circle-o'       => ['times-circle',               'far'],    # f057
    'times-rectangle'      => ['window-close',               'fas'],    # f410
    'times-rectangle-o'    => ['window-close',               'far'],    # f410
    'toggle-down'          => ['caret-square-down',          'far'],    # f150
    'toggle-left'          => ['caret-square-left',          'far'],    # f191
    'toggle-right'         => ['caret-square-right',         'far'],    # f152
    'toggle-up'            => ['caret-square-up',            'far'],    # f151
    'trash'                => ['trash-alt',                  'fas'],    # f2ed
    'trash-o'              => ['trash-alt',                  'far'],    # f2ed
    'trello'               => ['trello',                     'fab'],    # f181
    'tripadvisor'          => ['tripadvisor',                'fab'],    # f262
    'try'                  => ['lira-sign',                  'fas'],    # f195
    'tumblr'               => ['tumblr',                     'fab'],    # f173
    'tumblr-square'        => ['tumblr-square',              'fab'],    # f174
    'turkish-lira'         => ['lira-sign',                  'fas'],    # f195
    'twitch'               => ['twitch',                     'fab'],    # f1e8
    'twitter'              => ['twitter',                    'fab'],    # f099
    'twitter-square'       => ['twitter-square',             'fab'],    # f081
    'unsorted'             => ['sort',                       'fas'],    # f0dc
    'usb'                  => ['usb',                        'fab'],    # f287
    'usd'                  => ['dollar-sign',                'fas'],    # f155
    'user-circle-o'        => ['user-circle',                'far'],    # f2bd
    'user-o'               => ['user',                       'far'],    # f007
    'vcard'                => ['address-card',               'fas'],    # f2bb
    'vcard-o'              => ['address-card',               'far'],    # f2bb
    'viacoin'              => ['viacoin',                    'fab'],    # f237
    'viadeo'               => ['viadeo',                     'fab'],    # f2a9
    'viadeo-square'        => ['viadeo-square',              'fab'],    # f2aa
    'video-camera'         => ['video',                      'fas'],    # f03d
    'vimeo'                => ['vimeo-v',                    'fab'],    # f27d
    'vimeo-square'         => ['vimeo-square',               'fab'],    # f194
    'vine'                 => ['vine',                       'fab'],    # f1ca
    'vk'                   => ['vk',                         'fab'],    # f189
    'volume-control-phone' => ['phone-volume',               'fas'],    # f2a0
    'warning'              => ['exclamation-triangle',       'fas'],    # f071
    'wechat'               => ['weixin',                     'fab'],    # f1d7
    'weibo'                => ['weibo',                      'fab'],    # f18a
    'weixin'               => ['weixin',                     'fab'],    # f1d7
    'whatsapp'             => ['whatsapp',                   'fab'],    # f232
    'wheelchair-alt'       => ['accessible-icon',            'fab'],    # f368
    'wikipedia-w'          => ['wikipedia-w',                'fab'],    # f266
    'window-close-o'       => ['window-close',               'far'],    # f410
    'window-maximize'      => ['window-maximize',            'far'],    # f2d0
    'window-restore'       => ['window-restore',             'far'],    # f2d2
    'windows'              => ['windows',                    'fab'],    # f17a
    'won'                  => ['won-sign',                   'fas'],    # f159
    'wordpress'            => ['wordpress',                  'fab'],    # f19a
    'wpbeginner'           => ['wpbeginner',                 'fab'],    # f297
    'wpexplorer'           => ['wpexplorer',                 'fab'],    # f2de
    'wpforms'              => ['wpforms',                    'fab'],    # f298
    'xing'                 => ['xing',                       'fab'],    # f168
    'xing-square'          => ['xing-square',                'fab'],    # f169
    'y-combinator'         => ['y-combinator',               'fab'],    # f23b
    'y-combinator-square'  => ['hacker-news',                'fab'],    # f1d4
    'yahoo'                => ['yahoo',                      'fab'],    # f19e
    'yc'                   => ['y-combinator',               'fab'],    # f23b
    'yc-square'            => ['hacker-news',                'fab'],    # f1d4
    'yelp'                 => ['yelp',                       'fab'],    # f1e9
    'yen'                  => ['yen-sign',                   'fas'],    # f157
    'yoast'                => ['yoast',                      'fab'],    # f2b1
    'youtube'              => ['youtube',                    'fab'],    # f167
    'youtube-play'         => ['youtube',                    'fab'],    # f167
    'youtube-square'       => ['youtube-square',             'fab'],    # f431

    'pulse' => ['spin-pulse', 'fa'],
);

my %fi_fa4 = (
    'address-book'      => '',
    'alert'             => 'warning',
    'align-center'      => '',
    'align-justify'     => '',
    'align-left'        => '',
    'align-right'       => '',
    'anchor'            => '',
    'archive'           => '',
    'arrows-compress'   => 'compress-alt',
    'arrows-expand'     => 'expand-alt',
    'arrows-out'        => 'arrows-alt',
    'arrow-down'        => '',
    'arrow-left'        => '',
    'arrow-right'       => '',
    'arrow-up'          => '',
    'asl'               => 'asl-interpreting',
    'asterisk'          => '',
    'at-sign'           => 'at',
    'battery-empty'     => 'battery-0',
    'battery-full'      => 'battery',
    'battery-half'      => 'battery-2',
    'bitcoin'           => '',
    'blind'             => '',
    'bluetooth'         => 'bluetooth-b',
    'bold'              => '',
    'book'              => '',
    'bookmark'          => '',
    'braille'           => '',
    'calendar'          => '',
    'camera'            => '',
    'check'             => '',
    'checkbox'          => 'check-square-o',
    'clock'             => 'clock-o',
    'cloud'             => '',
    'comment'           => '',
    'comments'          => '',
    'compass'           => '',
    'contrast'          => 'adjust',
    'credit-card'       => '',
    'css3'              => '',
    'dislike'           => 'thumbs-down',
    'dollar'            => '',
    'download'          => '',
    'eject'             => '',
    'euro'              => '',
    'eye'               => '',
    'fast-forward'      => 'forward',
    'female'            => '',
    'female-symbol'     => 'venus',
    'filter'            => '',
    'first-aid'         => 'medkit',
    'flag'              => '',
    'folder'            => '',
    'graph-pie'         => 'pie-chart',
    'graph-trend'       => 'line-chart',
    'hearing-aid'       => 'assistive-listening-systems',
    'heart'             => '',
    'home'              => '',
    'html5'             => '',
    'indent-less'       => 'dedent',
    'indent-more'       => 'indent',
    'info'              => 'info-circle',
    'italic'            => '',
    'key'               => '',
    'laptop'            => '',
    'like'              => 'thumbs-up',
    'link'              => '',
    'list'              => 'bars',
    'list-bullet'       => 'list-ul',
    'list-number'       => 'list-ol',
    'list-thumbnails'   => 'list',
    'lock'              => '',
    'loop'              => 'refresh',
    'magnifying-glass'  => 'search',
    'mail'              => 'envelope',
    'male'              => '',
    'male-symbol'       => 'mars',
    'marker'            => 'map-marker',
    'megaphone'         => 'bullhorn',
    'microphone'        => '',
    'minus'             => '',
    'minus-circle'      => '',
    'mobile'            => '',
    'monitor'           => 'television',
    'music'             => '',
    'next'              => 'fast-forward',
    'page'              => 'file-o',
    'page-copy'         => 'files-o',
    'page-filled'       => 'file',
    'page-pdf'          => 'file-pdf-o',
    'paperclip'         => '',
    'pause'             => '',
    'paw'               => '',
    'paypal'            => '',
    'pencil'            => '',
    'photo'             => '',
    'play'              => '',
    'play-circle'       => 'play-circle-o',
    'plus'              => '',
    'pound'             => 'gbp',
    'power'             => 'power-off',
    'previous'          => 'fast-backward',
    'price-tag'         => 'tag',
    'pricetag-multiple' => 'tags',
    'print'             => '',
    'prohibited'        => 'ban',
    'puzzle'            => 'puzzle-piece',
    'refresh'           => '',
    'rewind'            => 'backward',
    'rss'               => '',
    'save'              => '',
    'share'             => '',
    'shield'            => '',
    'shopping-bag'      => '',
    'shopping-cart'     => '',
    'shuffle'           => 'random',
    'star'              => '',
    'stop'              => '',
    'strikethrough'     => '',
    'subscript'         => '',
    'superscript'       => '',
    'tablet-landscape'  => 'tablet fa-rotate-270',
    'tablet-portrait'   => 'tablet',
    'target'            => 'bullseye',
    'telephone'         => 'phone',
    'thumbnails'        => 'th',
    'ticket'            => '',
    'torso'             => 'user',
    'torsos-all'        => 'users',
    'trash'             => '',
    'trophy'            => '',
    'underline'         => '',
    'universal-access'  => '',
    'unlink'            => '',
    'unlock'            => '',
    'upload'            => '',
    'upload-cloud'      => 'cloud-upload',
    'video'             => 'video-camera',
    'volume'            => 'volume-up',
    'volume-none'       => 'volume-off',
    'wheelchair'        => 'wheelchair-alt',
    'widget'            => 'cog',
    'wrench'            => '',
    'x'                 => 'xmark',
    'x-circle'          => 'times-circle-o',
    'yen'               => '',
    'zoom-in'           => 'search-plus',
    'zoom-out'          => 'search-minus',
);

my %fi_fa6 = (
    'arrows-in'          => ['minimize',                  'fas'],
    'bitcoin-circle'     => ['bitcoin',                   'fab'],
    'book-bookmark'      => ['book-bookmark',             'fas'],
    'burst'              => ['burst',                     'fas'],
    'clipboard'          => ['clipboard',                 'far'],
    'closed-caption'     => ['closed-captioning',         'fas'],
    'crop'               => ['crop-simple',               'fas'],
    'crown'              => ['crown',                     'fas'],
    'die-one'            => ['dice-one',                  'fas'],
    'die-two'            => ['dice-two',                  'fas'],
    'die-three'          => ['dice-three',                'fas'],
    'die-four'           => ['dice-four',                 'fas'],
    'die-five'           => ['dice-five',                 'fas'],
    'die-six'            => ['dice-six',                  'fas'],
    'elevator'           => ['elevator',                  'fas'],
    'folder-add'         => ['folder-plus',               'fas'],
    'graph-horizontal'   => ['chart-simple fa-rotate-90', 'fas'],
    'graph-bar'          => ['chart-simple',              'fas'],
    'no-smoking'         => ['ban-smoking',               'fas'],
    'paint-bucket'       => ['fill-drip',                 'fas'],
    'record'             => ['circle-dot',                'fas'],
    'skull'              => ['skull-crossbones',          'fas'],
    'social-blogger'     => ['blogger',                   'fab'],
    'social-drive'       => ['google-drive',              'fab'],
    'social-evernote'    => ['evernote',                  'fab'],
    'social-facebook'    => ['facebook-square',           'fab'],
    'social-reddit'      => ['reddit-alien',              'fab'],
    'social-steam'       => ['steam-symbol',              'fab'],
    'social-stumbleupon' => ['stumbleupon-circle',        'fab'],
    'social-tumblr'      => ['square-tumblr',             'fab'],
    'social-vimeo'       => ['vimeo-square',              'fab'],
    'social-xbox'        => ['xbox',                      'fab'],
    'ticket'             => ['ticket',                    'fas'],
    'torso-business'     => ['user-tie',                  'fas'],
    'torsos'             => ['user-group',                'fas'],
);

sub _conv_fa_names {
    my @names = split /\s+/, shift;
    my $prefix = '';

    foreach (@names) {
        if (/\Afa-(.+)\z/) {
            my ($new, $pre) = @{$fa4_fa6{$1} || [$1, 'fa']};
            if ($prefix and $prefix ne $pre) {
                if ($prefix =~ /fas?\z/ and $pre =~ /fas?\z/) {
                    $pre = 'fas';
                } else {
                    warn "$new: $prefix vs $pre\n";
                }
            }

            $prefix = $pre;
            $_      = "fa-$new";
        }
    }
    $prefix ||= 'fa';
    @names = map { ($_ eq 'fa') ? $prefix : $_ } @names;

    return join ' ', @names;
}

sub _conv_fi_name {
    my @names = split /\s+/, shift;
    my $prefix = '';

    foreach (@names) {
        next unless /\Afi-(.+)\z/;
        my $name = $1;

        if (my $add = $fi_fa6{$name}) {
            $prefix = $add->[1];
            $_      = 'fa-' . $add->[0];
        } elsif ($name =~ s/\Asocial-//) {
            next unless $fa4_fa6{$name};

            $prefix = 'fa';
            $_      = "fa-$name";
        } elsif (my $new = $fi_fa4{$name}) {
            $prefix = 'fa';
            $_      = "fa-$new";
        } elsif (defined $fi_fa4{$name}) {
            $prefix = 'fa';
            $_      = "fa-$name";
        }
    }

    if ($prefix) {
        if ($prefix eq 'fa') {
            return _conv_fa_names(join ' ', $prefix, @names);
        } else {
            return join ' ', $prefix, @names;
        }
    } else {
        return join ' ', @names;
    }
}

sub _run {
    my $class   = shift;
    my $options = shift;

    my @directories;
    my @templates;

    if (-d "$Conf::Conf{'etc'}/web_tt2") {
        push @directories, "$Conf::Conf{'etc'}/web_tt2";
    }
    if (-f "$Conf::Conf{'etc'}/mhonarc_rc.tt2") {
        push @templates, "$Conf::Conf{'etc'}/mhonarc_rc.tt2";
    }

    foreach my $vr (keys %{$Conf::Conf{'robots'}}) {
        if (-d "$Conf::Conf{'etc'}/$vr/web_tt2") {
            push @directories, "$Conf::Conf{'etc'}/$vr/web_tt2";
        }
        if (-f "$Conf::Conf{'etc'}/$vr/mhonarc_rc.tt2") {
            push @templates, "$Conf::Conf{'etc'}/$vr/mhonarc_rc.tt2";
        }
    }

    my $all_lists = Sympa::List::get_lists('*');
    foreach my $list (@$all_lists) {
        if (-d ($list->{'dir'} . '/web_tt2')) {
            push @directories, $list->{'dir'} . '/web_tt2';
        }
        if (-f ($list->{'dir'} . '/mhonarc_rc.tt2')) {
            push @templates, $list->{'dir'} . '/mhonarc_rc.tt2';
        }
    }

    foreach my $d (@directories) {
        my $dh;
        unless (opendir $dh, $d) {
            printf STDERR "Error: Cannot read %s directory: %s", $d, $ERRNO;
            next;
        }

        foreach my $tt2 (sort grep {/[.]tt2$/} readdir $dh) {
            push @templates, "$d/$tt2";
        }

        closedir $dh;
    }

    my $umask = umask 022;

    foreach my $tpl (sort @templates) {
        process($tpl, $options);
    }

    umask $umask;
}

sub process {
    my $in      = shift;
    my $options = shift;

    my $ifh;
    unless (open $ifh, '<', $in) {
        warn sprintf "%s: %s\n", $in, $ERRNO;
        return;
    }
    $_ = do { local $RS; <$ifh> };
    close $ifh;
    my $orig = $_;

    my $out = '';
    my $ofh = IO::Scalar->new(\$out);

    pos $_ = 0;
    while (
        m{
          \G
          (
            [^<]+
          | <i\s+[^>]*?\bclass="([^"]*\bfa\b[^"]*)"[^>]*>
          | <i\s+[^>]*?\bclass="(fi-[^"]*)"[^>]*>
          | <[^>]*>
          )
        }cgsx
    ) {
        if (defined $2) {
            my ($elm, $cls) = ($1, $2);
            $cls =~ s/\A\s+//;
            $cls =~ s/\s+\z//;
            my $new = _conv_fa_names($cls);
            $elm =~ s/\bclass="[^"]+"/class="$new"/
                unless $new eq $cls;
            print $ofh $elm;
        } elsif (defined $3) {
            my ($elm, $cls) = ($1, $3);
            $cls =~ s/\A\s+//;
            $cls =~ s/\s+\z//;
            my $new = _conv_fi_name($cls);
            $elm =~ s/\bclass="[^"]+"/class="$new"/
                unless $new eq $cls;
            print $ofh $elm;
        } else {
            print $ofh $1;
            next;
        }
    }

    if ($orig eq $out) {
        warn sprintf "%s: no changes.\n", $in unless $options->{noout};
    } else {
        warn sprintf "%s: updated.\n", $in unless $options->{noout};
        unless ($options->{dry_run}) {
            unless (rename $in, sprintf '%s.upgrade%d', $in, time()) {
                warn "%s: %s\n", $in, $ERRNO;
                return;
            }
            if (open my $ofh, '>', $in) {
                print $ofh $out;
                Sympa::Tools::File::set_file_rights(
                    file  => $in,
                    user  => Sympa::Constants::USER(),
                    group => Sympa::Constants::GROUP()
                );
            } else {
                warn "%s: %s\n", $in, $ERRNO;
                return;
            }
        }
    }
}

1;
__END__

=encoding utf-8

=head1 NAME

sympa-upgrade-webfont - Upgrading font in web templates

=head1 SYNOPSIS

  sympa upgrade webfont [--dry_run|-n]

=head1 OPTIONS

=over

=item --dry_run|-n

Shows what will be done but won't really perform the upgrade process.

=back

=head1 DESCRIPTION

Versions 6.2.72 or later uses Font Awesome Free which is not compatible to
Font Awesome 4.x or earlier.
To solve this problem, this command upgrades customized web templates.

=head1 HISTORY

This command appeared on Sympa 6.2.72.

=cut

