package core.modules.sky;

import core.math.Matrix4f;
import core.scene.GameObject;
import core.shaders.Shader;
import core.utils.ResourceLoader;

public class AtmosphereShader extends Shader{

	private static AtmosphereShader instance = null;
	
	public static AtmosphereShader getInstance() {
		if(instance == null)
			instance = new AtmosphereShader();
		return instance;
	}
	
	protected AtmosphereShader() {
		super();
				
		addVertexShader(ResourceLoader.loadShader("shaders/sky/atmosphere_VS.glsl"));
		addFragmentShader(ResourceLoader.loadShader("shaders/sky/atmosphere_FS.glsl"));
		compileShader();
		
		addUniform("m_MVP");
		addUniform("m_World");
	}
	
	public void updateUniforms(GameObject object) {
		super.setUniform("m_MVP", object.getWorldTransform().getMVPMatrix());
		super.setUniform("m_World", object.getWorldTransform().getWorldMatrix());
	}
}
