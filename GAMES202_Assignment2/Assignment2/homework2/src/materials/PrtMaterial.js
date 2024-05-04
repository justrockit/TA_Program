class PrtMaterial extends Material {

    constructor(vertexShader, fragmentShader) {
        super({
            'aPrecomputeLR': { type: 'precomputeL', value: null },
            'aPrecomputeLG': { type: 'precomputeL', value: null },
            'aPrecomputeLB': { type: 'precomputeL', value: null },
        }, ["aPrecomputeLT"], vertexShader, fragmentShader, null,);
        //Edit End
    }
}

//Edit Start 添加rotate、lightIndex参数
async function buildPrtMaterial(vertexPath, fragmentPath) {
    //Edit End
    let vertexShader = await getShaderString(vertexPath);
    let fragmentShader = await getShaderString(fragmentPath);
    //Edit Start 添加rotate、lightIndex参数
    return new PrtMaterial(vertexShader, fragmentShader);
    //Edit End
}