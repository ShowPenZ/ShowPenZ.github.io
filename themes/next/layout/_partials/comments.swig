{% if page.comments %}

  {% if theme.facebook_sdk.enable and theme.facebook_comments_plugin.enable %}
    <div class="comments" id="comments">
      <div class="fb-comments"
           data-href="{{ page.permalink }}"
           data-numposts="{{ theme.facebook_comments_plugin.num_of_posts }}"
           data-width="{{ theme.facebook_comments_plugin.width }}"
           data-colorscheme="{{ theme.facebook_comments_plugin.scheme }}">
      </div>
    </div>

  {% elif theme.vkontakte_api.enable and theme.vkontakte_api.comments %}
    <div class="comments" id="comments">
      <div id="vk_comments"></div>
    </div>

  {% elif theme.disqus.enable or (theme.disqusjs.enable and theme.disqusjs.apikey and theme.disqusjs.shortname) %}
    <div class="comments" id="comments">
      <div id="disqus_thread">
        <noscript>{#
        #}Please enable JavaScript to view the comments powered by Disqus.{#
      #}</noscript>
      </div>
    </div>

  {% elif theme.livere_uid %}
   <iframe title="livere"   src="https://was.livere.me/comment/city?id=city&refer={{page.permalink}}&uid={{theme.livere_uid}}&site={{page.permalink}}&title={{page.title}}" scrolling="" frameborder="0" id="lv-comment-399" style="min-width: 100%; width: 100px; min-height: 400px; overflow: auto; border: 0px; z-index: 124212; height: 800px;" ></iframe>

  {% elif theme.changyan.enable and theme.changyan.appid and theme.changyan.appkey %}
    <div class="comments" id="comments">
      <div id="SOHUCS"></div>
    </div>

  {% elif theme.gitment.enable %}
    <div class="comments" id="comments">
      {% if theme.gitment.lazy %}
        <div onclick="showGitment()" id="gitment-display-button">{{ __('gitmentbutton') }}</div>
        <div id="gitment-container" style="display: none"></div>
      {% else %}
        <div id="gitment-container"></div>
      {% endif %}
    </div>

  {% elif theme.valine.enable and theme.valine.appid and theme.valine.appkey %}
    <div class="comments" id="comments">
    </div>

  {% elif theme.gitalk.enable %}
    <div class="comments" id="gitalk-container">
    </div>

  {% endif %}

{% endif %}
