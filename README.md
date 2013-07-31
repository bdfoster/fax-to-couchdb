fax-to-couchdb
==============

Lua script to insert faxes from Freeswitch into existing couchdb database.

How to use
----------
0. Ensure you have a proper couchdb instance running and working properly. This is your responsibility!
1. git clone this project into a directory that freeswitch has permissions to.
 - suggestion: $${base_dir}/scripts/lua/fax-to-couchdb
2. Install luchia, the couchdb library: https://thehunmonkgroup.github.com/luchia
 - You can (and should) use LuaRocks to install this library. On a Debian/Ubuntu system, this can be done like so:
   sudo apt-get install luarocks
   luarocks install luchia
3. Use the example config file (example_config.lua) to set up your server settings. When you change it, save the file as config.lua.
4. Create your fax extension (if you haven't already done so):
 - This is what mine looks like:

`<include>
  <extension name="faxrx">
    <condition field="destination_number" expression="^faxrx$|^/*11$|^3000$">
      <action application="set" data="fax_enable_t38=true"/>
      <action application="set" data="fax_enable_t38_request=true"/>
      <action application="answer"/>
      <action application="playback" data="silence_stream://2000"/>
      <action application="rxfax" data="$${base_dir}/storage/fax/FAX-${uuid}.tif"/>
    </condition>
  </extension>
</include>`

5. Just before the answer application in our extension, we're going to insert this line:

      `<action application="set" data="execute_on_fax_result=lua $${base_dir}/lua/fax-to-couchdb/fax-to-couchdb.lua \\\${fax_filename} ${caller_id_name} ${caller_id_number} ${destination_number} \\\${fax_document_transferred_pages} \\\${fax_result_code} \\\${fax_result_text} \\\${fax_transfer_rate} \\\${fax_ecm_used} \\\${fax_bad_rows} ${uuid}"/>`

I know, it's long. We're passing variables to the script using this so that we can store these in the database.

6. Test, test, test. Should work just fine. If not, open up an issue on Github (http://github.com/bdfoster/fax-to-couchdb/issues).

Notes:

The test system used in the development of this script is a Debian-based system. It should work with all linux variants. I cannot guarentee
that it will work with Windows anything, as I don't have a Windows-based machine available to me. If you have a suggestion that would make
it work on Windows-based systems, open up an issue (using the URL above).

