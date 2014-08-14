/**
 * @autor rcam
 * @date 15.07.2014.
 * @company Gameduell GmbH
 */
package duell.objects;

import duell.helpers.LogHelper;
import duell.helpers.ProcessHelper;

import duell.helpers.DuellLibListHelper;

import sys.FileSystem;

using StringTools;

class DuellLib 
{
	public var name(default, null) : String;
	public var version(default, null) : String;
	private var path : String = null; ///use getters

	private function new(name : String, version : String = '')
	{
		this.name = name;
		this.version = version;
	}

	public static var duellLibCache : Map<String, Map<String, DuellLib> > = new Map<String, Map<String, DuellLib> >();
	public static function getDuellLib(name : String, version : String = '')
	{
		///add to the cache if it is not there
		if (duellLibCache.exists(name))
		{
			var versionMap = duellLibCache.get(name);
			if (!versionMap.exists(version))
			{
				versionMap.set(version, new DuellLib(name, version));
			}
		}
		else
		{
			var versionMap = new Map<String, DuellLib>();
			versionMap.set(version, new DuellLib(name, version));
			duellLibCache.set(name, versionMap);
		}

		///retrieve from the cache
		return duellLibCache.get(name).get(version);
	}

	public function setPath(path : String)
	{
		this.path = path;
	}

	public function exists()
	{
		var output = '';
		
		var prevVerbose = LogHelper.verbose;
		LogHelper.verbose = false;
		try 
		{
			var nameToTry = name;
			if(version != '')
				nameToTry += ':' + version;
			output = ProcessHelper.runProcess(Sys.getEnv ('HAXEPATH'), 'haxelib', ['path', nameToTry], true, true, true);
		} 
		catch (e:Dynamic) { }
		LogHelper.verbose = prevVerbose;

		if(output.indexOf('is not installed') != -1)
			return false;
		else
			return true;
	}

	public function getPath() : String
	{
		if(path != null)
			return path;

		if(!exists())
		{
			if (version != '') 
			{
				LogHelper.error ('Could not find duellLib \'' + name + '\' version \'' + version + '\', does it need to be installed?');
			} 
			else 
			{
				LogHelper.error ('Could not find duellLib \'' + name + '\', does it need to be installed?');
			}
		}

		var prevVerbose = LogHelper.verbose;
		LogHelper.verbose = false;
		var output = '';
		try 
		{
			var nameToTry = name;
			if(version != '')
				nameToTry += ':' + version;
			output = ProcessHelper.runProcess(Sys.getEnv('HAXEPATH'), 'haxelib', ['path', nameToTry], true, true, true);
		} 
		catch (e:Dynamic) { }
		
		LogHelper.verbose = prevVerbose;
			
		var lines = output.split ('\n');
			
		for (i in 1...lines.length) {
			
			if (lines[i].trim() == '-D ' + name) 
			{
				path = lines[i - 1].trim();
			}
			
		}

		if (path == '') 
		{
			try {
				for (line in lines) 
				{
					if (line != '' && line.substr(0, 1) != '-') 
					{
						if (FileSystem.exists(line)) 
						{
							path = line;
							break;
						}
					}
				}
			} catch (e:Dynamic) {}
			
		}
		
		return path;
	}

    public function updateNeeded() : Bool
    {
        var duellLibList = DuellLibListHelper.getDuellLibReferenceList();

        if (duellLibList.exists(name))
        {
            return duellLibList.get(name).updateNeeded();
        }
        else
        {
            LogHelper.error('Couldn\'t find the Duell Library reference in the repo list for $name. Can\'t check for updates.');
            return false;
        }
    }

    public function update()
    {
        var duellLibList = DuellLibListHelper.getDuellLibReferenceList();

        if (duellLibList.exists(name))
        {
            duellLibList.get(name).update();
        }
        else
        {
            LogHelper.error('Couldn\'t find the Duell Library reference in the repo list for $name. Can\'t update it.');
        }
    }

    public function install()
    {
        var duellLibList = DuellLibListHelper.getDuellLibReferenceList();

        if (duellLibList.exists(name))
        {
            duellLibList.get(name).install();
        }
        else
        {
            LogHelper.error('Couldn\'t find the Duell Library reference in the repo list for $name. Can\'t install it.');
        }
    }
}