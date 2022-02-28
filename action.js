const core = require('@actions/core');
const exec = require('@actions/exec');
const path = require('path')

core.setCommandEcho(true)

async function run() {
    try {
        let target = core.getInput('target', { required: false })
        let zipVersion = core.getInput('zip-version', { required: true })
        let outputPath = core.getInput('output-path', { required: false })

        // build options
        var options = ['-target']
        options.push(target)

        options.push('-zip-version')
        options.push(zipVersion)

        if (!!outputPath) {
            options.push('-output-path')
            options.push(outputPath)
        }

        await exec.exec('sh',[ path.join(__dirname, "create_xcframework.sh"), ...options])

    } catch (error) {
        core.setFailed(error)
    }
}

run()