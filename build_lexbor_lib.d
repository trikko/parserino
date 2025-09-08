/+ dub.sdl:
	name "build_lib"
+/
module build_lexbor_lib;

import std;

int main()
{

    version(WINDOWS)
    {
        return 0;
    }
    else
    {
        enum commit = "7fb22cf5664a331d7c24b113489e566767c9c25a";

        // Ok, already done.
        if (exists("liblexbor_parserino.a"))
            return 0;

        // Temp directory
        auto path = tempDir.buildPath(tempDir(), "lexbor_build", "lexbor_bundle.zip");
        mkdirRecurse(dirName(path));

        auto cmake = executeShell("cmake --help");

        if (cmake.status != 0)
        {
            version(linux) stderr.writeln("Please install cmake on your system. For example on debian/ubuntu/... : `sudo apt install cmake`");
            version(OSX) stderr.writeln("Please install cmake on your system. Try: `brew install cmake`");
            return 1;
        }

        stderr.writeln;
        stderr.writeln("-------------------------");
        stderr.writeln("-- One time deps build --");
        stderr.writeln("-------------------------");
        stderr.writeln;

        stderr.writeln("- Temp. directory: ", path); stderr.flush();

        // Download bundle
        stderr.writeln("- Getting zip bundle..."); stderr.flush();
        download("https://github.com/lexbor/lexbor/archive/" ~ commit ~ ".zip", path);

        // Unzip
        stderr.writeln("- Unzipping bundle..."); stderr.flush();
        ZipArchive zip = new ZipArchive(path.read);

        foreach(string amPath, ref ArchiveMember am; zip.directory)
        {
            auto relPath = amPath;
            auto filePath = tempDir.buildPath(tempDir(), "lexbor_build", relPath);
            mkdirRecurse(dirName(filePath));

            zip.expand(am);

            if (!filePath.endsWith("/") && !filePath.endsWith("\\"))
                std.file.write(filePath, am.expandedData());
        }

        // Compiling
        stderr.writeln("- Compiling... (please wait, this will not be done anymore!)"); stderr.flush();

        string cmakeopt;
        version(OSX) cmakeopt = " -DCMAKE_OSX_DEPLOYMENT_TARGET=10.10 ";

        auto res = executeShell("cd " ~ dirName(path).buildPath("lexbor-" ~ commit) ~ " && cmake . -DLEXBOR_BUILD_TESTS=OFF -DLEXBOR_BUILD_EXAMPLES=OFF -DLEXBOR_BUILD_SEPARATELY=OFF -DLEXBOR_BUILD_SHARED=OFF -DLEXBOR_BUILD_STATIC=ON " ~ cmakeopt ~ " && make");

        stderr.writeln("- Waiting for result..."); stderr.flush();
        auto outputFile = dirName(path).buildPath("lexbor-" ~ commit, "liblexbor_static.a");

        bool done = true;

        SysTime tm = Clock.currTime();
        while(!outputFile.exists && done)
        {
            import core.thread;
            Thread.sleep(150.dur!"msecs");

            if (Clock.currTime() - tm > 5.dur!"seconds")
                done = false;
        }

        if (done)
        {
            stderr.writeln("--- DONE ---\n");
            copy(dirName(path).buildPath("lexbor-" ~ commit, "liblexbor_static.a"), "liblexbor_parserino.a");
        }
        else
        {
            stderr.writeln("--- BUILD FAIL ---\nCompiler output:\n", res.output);
            return 2;
        }

        return 0;
    }
}
