changequote(«,»)dnl
define(«DIALOGUE», «dnl
<div class="dialogue">
DIALOGUE_BODY($@)dnl
</div>dnl
»)dnl
define(«DIALOGUE_BODY»,
«ifelse(«$#», «0», «$0»,
        «$#», «1», «$1»,
        «$1 DIALOGUE_BODY(shift($@))»)dnl
»)dnl
define(«MESSAGE», «dnl
<div class="message $3">
<div class="character $3">
<figure class="$1 sprite">
<img src="/static/img/$1-$2.svg" alt="$1 says:">
</figure>
</div>
<div class="bubble-wrap">
<div class="bubble $3 $4">
<p>$5</p>
</div>
</div>
</div>dnl
»)dnl
define(«META», «dnl
<nav>
<div class="date">
<p><time datetime="$1-$2-$3">$1 MONTH($2) $3</time></p>
</div>
<div class="tags">
LINK_TAGS($4)
</div>
</nav>dnl
»)dnl
define(«LINK_TAGS»,
«ifelse(«$#», «0», «got nothing»,
        «$#», «1», «LINK_TAG($1)»,
        «LINK_TAG($1)
LINK_TAGS(shift($@))»)»)dnl
define(«LINK_TAG», <a href="/" class="link tag">$1</a>)dnl
define(«ROW», «dnl
<tr>
<td class="date">
<time datetime="$4-$5-$6">$4 MONTH($5) $6</time>
</td>
<td class="title">
<a href="/posts/$3" rel="bookmark" title="Permalink to: '$2'">$1</a>
</td>
<td class="tags">
TAGS($7) 
</td>
</tr>dnl
»)dnl
define(«TAGS»,
«ifelse(«$#», «0», «got nothing»,
        «$#», «1», «TAG($1)»,
        «TAG($1)
TAGS(shift($@))»)»)dnl
define(«TAG», <button class="tag" type="button">$1</button>)dnl
define(«MONTH»,
«ifelse(«$1», «01», «Jan»,
        «$1», «02», «Feb»,
        «$1», «03», «Mar»,
        «$1», «04», «Apr»,
        «$1», «05», «May»,
        «$1», «06», «Jun»,
        «$1», «07», «Jul»,
        «$1», «08», «Aug»,
        «$1», «09», «Sep»,
        «$1», «10», «Oct»,
        «$1», «11», «Nov»,
        «$1», «12», «Dec»,
        «bad value: $1»)»)dnl
